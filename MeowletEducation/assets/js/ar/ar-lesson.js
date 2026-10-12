// Runs an AR lesson on course.aspx. The page provides:
//   #arData      JSON: { lessonId, scene, config, canSave, saveUrl, nextUrl, finishedUrl }
//   #arCanvas    where the 3D view is drawn
//   #arUi        instruction + controls; becomes the full-screen overlay in AR
//   #arStartAr   "Place it on my table" button (shown only when AR is available)
//   #arStartTrack "Use the Meowlet card" button (shown when the browser can use a camera)
//   #arPrintCard  link to the printable card
// The scene module (budget-jars.js, compound-growth.js) does the activity and calls
// api.finish(result); this file shows the result, saves it and moves on.

import { Stage, arSupported, cameraSupported, webglSupported } from './ar-core.js';
import { loadMindAR, cardTarget } from './ar-card.js';

const SCENES = {
    'budget-jars': () => import('./budget-jars.js'),
    'compound-growth': () => import('./compound-growth.js')
};

const $ = id => document.getElementById(id);
const data = JSON.parse($('arData').textContent);
const ui = $('arUi');
const instruction = $('arInstruction');
const controlsSlot = $('arControls');
const startAr = $('arStartAr');
const startTrack = $('arStartTrack');
const printCard = $('arPrintCard');
const exitAr = $('arExit');
const hint = $('arModeHint');

function showFallback(message) {
    instruction.textContent = message;
    const fallback = document.querySelector('[data-ar-fallback]');
    if (fallback) fallback.hidden = false;
    $('arStage').classList.add('is-broken');
}

// Taps on our buttons and sliders must not also count as taps in the AR scene.
ui.addEventListener('beforexrselect', e => {
    if (e.target.closest && e.target.closest('.ar-panel, button, input, a')) e.preventDefault();
});

async function main() {
    if (!webglSupported()) {
        showFallback('This browser can\'t show 3D. Read the steps below, then mark the lesson complete.');
        return;
    }
    if (!SCENES[data.scene]) {
        showFallback('This AR activity isn\'t available yet.');
        return;
    }

    let config = {};
    try { config = data.config ? JSON.parse(data.config) : {}; } catch (e) { config = {}; }

    const stage = new Stage($('arCanvas'));
    const startedAt = Date.now();
    let modeUsed = '3d';
    let sceneInstruction = '';
    let controls = null;

    const api = {
        setInstruction(text) {
            sceneInstruction = text;
            if (stage.mode === 'ar' && !stage.placed) return; // placement hint stays until placed
            if (stage.mode === 'tracking' && !stage.cardVisible) return; // "point at the card" stays until found
            instruction.textContent = text;
        },
        setControls(node) {
            controls = node;
            controlsSlot.replaceChildren(node);
        },
        finish: result => showResult(result)
    };

    const module = await SCENES[data.scene]();
    const activity = module.create(stage, config, api);

    // ?ardebug in the URL exposes the stage for testing from the browser console.
    if (new URLSearchParams(location.search).has('ardebug')) window.meowletAr = { stage, activity };

    // ----- Meowlet card tracking (laptop webcam, iPhone, any phone) -----
    if (startTrack && cameraSupported()) {
        startTrack.hidden = false;
        if (printCard) printCard.hidden = false;
        startTrack.onclick = async () => {
            if (stage.mode === 'tracking') {
                stage.stopTracking();
                return;
            }
            startTrack.disabled = true;
            const status = text => { if (text) instruction.textContent = text; };
            try {
                status('Loading the card tracker...');
                const mindar = await loadMindAR();
                const target = await cardTarget(mindar, status);
                await stage.startTracking({
                    Controller: mindar.Controller,
                    target,
                    onStatus: status,
                    onFound: () => { instruction.textContent = sceneInstruction; },
                    onLost: () => { instruction.textContent = 'Card lost. Bring the Meowlet card back into view.'; }
                });
                instruction.textContent = 'Point the camera at the Meowlet card. The activity appears on it.';
                hint.textContent = 'Hold the card flat and well lit, filling about a third of the camera picture. Tap the activity on screen to interact.';
            } catch (e) {
                instruction.textContent = sceneInstruction;
                hint.textContent = e && e.name === 'NotAllowedError'
                    ? 'Camera access was blocked. Allow the camera for this site in the browser\'s address bar, then try again.'
                    : e && e.name === 'NotFoundError'
                        ? 'No camera was found on this device.'
                        : 'Card tracking could not start: ' + ((e && e.message) || e) + '.';
            }
            startTrack.disabled = false;
        };
    }

    // ----- AR on supported phones -----
    if (await arSupported()) {
        startAr.hidden = false;
        hint.textContent = 'Your phone can place this activity on a real table.';
        startAr.onclick = async () => {
            try {
                await stage.startAR(ui);
                modeUsed = 'ar';
            } catch (e) {
                hint.textContent = 'AR could not start (' + e.message + '). You can still do the activity in 3D above.';
            }
        };
    } else {
        hint.textContent = 'Drag to turn the scene, tap to interact. On an Android phone with Chrome you can also place it on a real table.';
    }

    stage.onModeChange = mode => {
        // Remember the most immersive way the learner used: ar > card > 3d.
        if (mode === 'ar') modeUsed = 'ar';
        else if (mode === 'tracking' && modeUsed !== 'ar') modeUsed = 'card';
        if (startTrack) {
            startTrack.innerHTML = mode === 'tracking'
                ? '<i class="bi bi-x-circle" aria-hidden="true"></i>&nbsp;Stop using the card'
                : '<i class="bi bi-qr-code-scan" aria-hidden="true"></i>&nbsp;Use the Meowlet card';
        }
        ui.classList.toggle('is-ar', mode === 'ar');
        exitAr.hidden = mode !== 'ar';
        instruction.textContent = mode === 'ar'
            ? 'Move your phone slowly over a table until a white ring appears, then tap to place the activity.'
            : sceneInstruction;
    };
    stage.onPlaced = () => { instruction.textContent = sceneInstruction; };
    exitAr.onclick = () => stage.endAR();

    // ----- result + save -----
    async function save(result) {
        if (!data.canSave) return { preview: true };
        const response = await fetch(data.saveUrl, {
            method: 'POST',
            credentials: 'same-origin',
            headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'MeowletAR' },
            body: JSON.stringify({
                lessonId: data.lessonId,
                mode: modeUsed,
                score: typeof result.score === 'number' ? result.score : null,
                summary: result.summary,
                result: JSON.stringify(result.detail || {}),
                seconds: Math.round((Date.now() - startedAt) / 1000)
            })
        });
        const body = await response.json().catch(() => ({}));
        if (!response.ok || !body.ok) throw new Error(body.error || ('server answered ' + response.status));
        return body;
    }

    function showResult(result) {
        const panel = document.createElement('div');
        panel.className = 'ar-panel ar-result';

        const title = document.createElement('p');
        title.className = 'ar-result__title';
        title.textContent = typeof result.score === 'number' ? 'Your result: ' + result.score + '%' : 'Your result';
        const summary = document.createElement('p');
        summary.textContent = result.summary;
        const list = document.createElement('ul');
        (result.feedback || []).forEach(line => {
            const li = document.createElement('li');
            li.textContent = line;
            list.appendChild(li);
        });
        const status = document.createElement('p');
        status.className = 'ar-result__status';
        status.textContent = 'Saving your result...';

        const actions = document.createElement('div');
        actions.className = 'ar-actions';
        const again = document.createElement('button');
        again.type = 'button';
        again.className = 'btn btn--ghost btn--sm';
        again.textContent = 'Try again';
        const next = document.createElement('button');
        next.type = 'button';
        next.className = 'btn btn--primary btn--sm';
        next.textContent = 'Continue';
        next.disabled = true;
        actions.append(again, next);

        panel.append(title, summary, list, status, actions);
        controlsSlot.replaceChildren(panel);
        instruction.textContent = 'Activity finished.';

        let goTo = null;
        again.onclick = () => {
            activity.reset();
            controlsSlot.replaceChildren(controls);
        };
        next.onclick = () => {
            if (stage.session) stage.endAR();
            if (stage.mode === 'tracking') stage.stopTracking();
            if (goTo) window.location.href = goTo;
        };

        save(result).then(r => {
            if (r.preview) {
                status.textContent = 'Preview: results aren\'t saved for tutors and admins.';
            } else {
                status.textContent = r.courseFinished
                    ? 'Saved. That was the last lesson: the course is complete!'
                    : 'Saved. This lesson is now marked complete.';
                goTo = r.courseFinished ? data.finishedUrl : data.nextUrl;
                next.disabled = false;
            }
        }).catch(e => {
            status.textContent = 'Your result could not be saved: ' + e.message + '. Try again, or check your connection.';
        });
    }
}

main().catch(e => {
    console.error(e);
    showFallback('The activity could not load (' + e.message + '). Read the steps below, then mark the lesson complete.');
});
