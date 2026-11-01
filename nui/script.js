const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'piercer_webview';
const $ = id => document.getElementById(id);

let currentSrc = null;
let currentId = null;
let mode = 'iframe';

function post(name, data) {
    fetch(`https://${resource}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data || {}),
    }).catch(() => {});
}

function buildSrc(data) {
    if (!data.sendParams) return data.url;
    try {
        const u = new URL(data.url);
        u.searchParams.set('id', data.id);
        if (data.name) u.searchParams.set('nome', data.name);
        return u.toString();
    } catch (err) {
        // URL relativa/inválida (ex.: Config.url sem https://): usa como veio
        return data.url;
    }
}

function copyText(text) {
    const t = document.createElement('textarea');
    t.value = text;
    document.body.appendChild(t);
    t.select();
    let ok = false;
    try { ok = document.execCommand('copy'); } catch (err) {}
    t.remove();
    return ok;
}

function sendStage() {
    if (mode !== 'dui' || $('app').hidden) return;
    const r = $('stage').getBoundingClientRect();
    if (r.width < 2 || r.height < 2) return;
    const W = window.innerWidth, H = window.innerHeight;
    post('duiStage', {
        x: r.left / W, y: r.top / H, w: r.width / W, h: r.height / H,
        pw: Math.round(r.width), ph: Math.round(r.height),
        url: currentSrc,
    });
}

function stagePos(e) {
    const r = $('stage').getBoundingClientRect();
    return {
        x: Math.min(1, Math.max(0, (e.clientX - r.left) / r.width)),
        y: Math.min(1, Math.max(0, (e.clientY - r.top) / r.height)),
    };
}

const BUTTONS = ['left', 'middle', 'right'];
let pendingMove = null;

$('stage').addEventListener('mousemove', e => {
    // junta os movimentos por frame pra não inundar o Lua de fetch
    const first = !pendingMove;
    pendingMove = stagePos(e);
    if (first) requestAnimationFrame(() => {
        if (pendingMove) post('duiMouse', pendingMove);
        pendingMove = null;
    });
});

const pressed = new Set();

$('stage').addEventListener('mousedown', e => {
    e.preventDefault();
    pendingMove = null;
    pressed.add(e.button);
    post('duiMouse', { ...stagePos(e), type: 'down', button: BUTTONS[e.button] });
});

// no documento: soltar o botão fora do #stage (arrastando) também conta
document.addEventListener('mouseup', e => {
    if (!pressed.delete(e.button)) return;
    post('duiMouse', { ...stagePos(e), type: 'up', button: BUTTONS[e.button] });
});

$('stage').addEventListener('wheel', e => {
    e.preventDefault();
    // deltaMode 1 = linhas (≈ 40px cada)
    const k = e.deltaMode === 1 ? 40 : 1;
    post('duiWheel', { dy: e.deltaY * k, dx: e.deltaX * k });
}, { passive: false });

$('stage').addEventListener('contextmenu', e => e.preventDefault());

window.addEventListener('resize', sendStage);

// ─────────────────────────────────────────────────────────────────────────────

function showNotice(data) {
    const dui = mode === 'dui';
    const show = dui || !!data.blocked;
    $('blocked').hidden = !show;
    $('blocked').classList.toggle('info', dui);
    $('blockedtitle').textContent = dui
        ? 'Modo compatível: mouse e rolagem funcionam, o teclado não.'
        : 'Este site não permite ser aberto dentro do jogo.';
    $('blockedwhy').textContent = !dui && data.blocked ? `(${data.blocked})` : '';
    $('copyurl').textContent = 'copiar link';
    // abre no navegador do Windows (função da própria NUI do FiveM)
    $('openext').hidden = typeof window.invokeNative !== 'function';
}

function open(data) {
    currentId = String(data.id);
    $('t-main').textContent = data.title || '';
    $('t-hl').textContent = data.highlight || '';
    document.title = [data.title, data.highlight].filter(Boolean).join(' ') || 'Site';
    if (data.color) document.documentElement.style.setProperty('--accent', data.color);

    $('idbox').hidden = !data.showId;
    $('hint').textContent = data.idHint || '';
    $('pid').textContent = currentId;
    $('copied').textContent = 'copiar';
    $('copied').className = '';

    mode = data.mode === 'dui' ? 'dui' : 'iframe';
    const src = buildSrc(data);

    if (mode === 'dui') {
        // a DUI é recriada a cada abertura (o Lua destrói ao fechar)
        currentSrc = src;
        $('frame').hidden = true;
        $('frame').src = 'about:blank';
    } else {
        $('frame').hidden = false;
        const changed = src !== currentSrc || $('frame').src === 'about:blank';
        currentSrc = src;
        if (changed) $('frame').src = src;
    }
    $('stage').hidden = mode !== 'dui';
    $('app').classList.toggle('dui', mode === 'dui');

    showNotice(data);

    $('app').hidden = false;
    $('close').focus();

    // a janela entra com animação de escala: mede o #stage só depois dela
    if (mode === 'dui') setTimeout(sendStage, 220);
}

function close() {
    $('app').hidden = true;
    pendingMove = null;
    pressed.clear();
}

function requestClose() {
    if ($('app').hidden) return;
    close();
    post('close');
}

window.addEventListener('message', e => {
    const data = e.data;
    if (!data || typeof data !== 'object') return;
    if (data.action === 'open') open(data);
    else if (data.action === 'close') close();
});


document.addEventListener('keydown', e => {
    if (e.key === 'Escape') requestClose();
});

$('close').onclick = requestClose;

$('reload').onclick = () => {
    if (mode === 'dui') post('duiReload');
    else if (currentSrc) $('frame').src = currentSrc;
};

$('copyurl').onclick = () => {
    if (!currentSrc) return;
    $('copyurl').textContent = copyText(currentSrc) ? 'copiado!' : 'copiar link';
};

$('openext').onclick = () => {
    if (currentSrc && typeof window.invokeNative === 'function') window.invokeNative('openUrl', currentSrc);
};

$('copy').onclick = () => {
    if (!currentId) return;
    const ok = copyText(currentId);
    $('copied').textContent = ok ? 'copiado!' : 'copiar';
    $('copied').className = ok ? 'ok' : '';
};
