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
    const u = new URL(data.url);
    u.searchParams.set('id', data.id);
    if (data.name) u.searchParams.set('nome', data.name);
    return u.toString();
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

    const src = buildSrc(data);
    if (src !== currentSrc) {
        currentSrc = src;
        $('frame').src = src;
    }
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

$('copy').onclick = () => {
    if (!currentId) return;
    const t = document.createElement('textarea');
    t.value = currentId;
    document.body.appendChild(t);
    t.select();
    let ok = false;
    try { ok = document.execCommand('copy'); } catch (err) {}
    t.remove();
    $('copied').textContent = ok ? 'copiado!' : 'copiar';
    $('copied').className = ok ? 'ok' : '';
};
