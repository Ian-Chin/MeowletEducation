// The Meowlet card: the printed picture that AR activities lock onto.
//
// Tracking uses MindAR (MIT licence, https://github.com/hiukim/mind-ar-js).
//   - A local copy in assets/js/vendor/mindar/ is used when present (works offline;
//     run tools/get-mindar.ps1 once to download it), otherwise the jsDelivr CDN.
//   - The card's tracking data ("target") comes from assets/ar/meowlet-card.mind if
//     that file exists. If not, it is built from assets/ar/meowlet-card.png in the
//     browser the first time (10-30 s) and kept in the browser cache afterwards.

const MINDAR_LOCAL = new URL('../vendor/mindar/mindar-image.prod.js', import.meta.url).href;
const MINDAR_CDN = 'https://cdn.jsdelivr.net/npm/mind-ar@1.2.5/dist/mindar-image.prod.js';

export const CARD = {
    image: new URL('../../ar/meowlet-card.png', import.meta.url).href,
    mind: new URL('../../ar/meowlet-card.mind', import.meta.url).href,
    print: new URL('../../ar/meowlet-card-print.html', import.meta.url).href
};

const CACHE_NAME = 'meowlet-ar';
const CACHE_KEY = CARD.image + '?compiled=mindar-1.2.5';

let mindarPromise = null;

export function loadMindAR() {
    if (!mindarPromise) {
        mindarPromise = import(MINDAR_LOCAL)
            .catch(() => import(MINDAR_CDN))
            .catch(() => { mindarPromise = null; throw new Error('the card tracker could not be downloaded. Check the internet connection'); });
    }
    return mindarPromise;
}

function loadImage(src) {
    return new Promise((resolve, reject) => {
        const img = new Image();
        img.onload = () => resolve(img);
        img.onerror = () => reject(new Error('the card picture (assets/ar/meowlet-card.png) is missing'));
        img.src = src;
    });
}

// Returns { buffer } with compiled tracking data for the card.
export async function cardTarget(mindar, onStatus) {
    // 1. A pre-built file next to the picture.
    try {
        const response = await fetch(CARD.mind, { cache: 'no-cache' });
        if (response.ok) return { buffer: await response.arrayBuffer() };
    } catch (e) { /* fall through */ }

    // 2. Built earlier in this browser.
    let cache = null;
    try {
        cache = await caches.open(CACHE_NAME);
        const hit = await cache.match(CACHE_KEY);
        if (hit) return { buffer: await hit.arrayBuffer() };
    } catch (e) { cache = null; }

    // 3. Build it now from the picture (one time per browser).
    onStatus('Getting the card tracker ready for the first time (about 10 to 30 seconds)...');
    const img = await loadImage(CARD.image);
    const compiler = new mindar.Compiler();
    await compiler.compileImageTargets([img], percent =>
        onStatus('Getting the card tracker ready for the first time... ' + Math.round(percent) + '%'));
    const data = compiler.exportData();
    const buffer = data.buffer.slice(data.byteOffset, data.byteOffset + data.byteLength);
    try { if (cache) await cache.put(CACHE_KEY, new Response(buffer)); } catch (e) { /* cache is optional */ }
    return { buffer };
}
