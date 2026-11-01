const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'piercer_browser';
const $ = id => document.getElementById(id);

let currentSrc = null;
let currentId = null;

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

    // O servidor já sabe (preflight) se o site recusa iframe — avisa em vez
    // de deixar o jogador olhando pra uma tela preta.
    $('blocked').hidden = !data.blocked;
    $('blockedwhy').textContent = data.blocked ? `(${data.blocked})` : '';
    $('copyurl').textContent = 'copiar link';

    const src = buildSrc(data);
    const changed = src !== currentSrc;
    currentSrc = src;
    if (changed) $('frame').src = src;

    $('app').hidden = false;
    $('close').focus();
}

function close() {
    $('app').hidden = true;
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
    if (currentSrc) $('frame').src = currentSrc;
};

$('copyurl').onclick = () => {
    if (!currentSrc) return;
    $('copyurl').textContent = copyText(currentSrc) ? 'copiado!' : 'copiar link';
};

$('copy').onclick = () => {
    if (!currentId) return;
    const ok = copyText(currentId);
    $('copied').textContent = ok ? 'copiado!' : 'copiar';
    $('copied').className = ok ? 'ok' : '';
};
