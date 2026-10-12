// Money tree: save a fixed amount every month and watch compound interest work.
// Three sliders (monthly amount, interest rate, years). Two coin stacks show
// what the learner put in versus what interest added; the tree grows with time.
//
// Lesson settings (CourseLessons.ARConfig), all optional:
//   { "currency": "RM", "monthly": 100, "ratePercent": 5, "years": 20 }

import { THREE, makeLabel, formatMoney } from './ar-core.js';

const DEFAULTS = { currency: 'RM', monthly: 100, ratePercent: 5, years: 20 };
const MAX_COINS = 60;

// Value after saving `monthly` at the end of every month for `years`, compounded monthly.
export function futureValue(monthly, ratePercent, years) {
    const n = Math.round(years * 12);
    const r = ratePercent / 100 / 12;
    return r === 0 ? monthly * n : monthly * (Math.pow(1 + r, n) - 1) / r;
}

const clamp = (v, lo, hi) => Math.min(hi, Math.max(lo, v));

function settings(config) {
    const cfg = Object.assign({}, DEFAULTS, config || {});
    cfg.monthly = clamp(Math.round(+cfg.monthly / 10) * 10 || DEFAULTS.monthly, 10, 2000);
    cfg.ratePercent = clamp(+cfg.ratePercent || 0, 0, 12);
    cfg.years = clamp(Math.round(+cfg.years) || DEFAULTS.years, 1, 40);
    return cfg;
}

export function create(stage, config, api) {
    const cfg = settings(config);
    stage.frame([0.02, 0.06, 0.06], [0, 0.36, 0.98]);
    const money = v => formatMoney(v, cfg.currency);
    const state = { monthly: cfg.monthly, rate: cfg.ratePercent, years: cfg.years };
    let changes = 0;
    let done = false;

    // One coin stands for a fixed amount, so the stacks visibly grow with years and rate.
    const unit = Math.max(1, futureValue(cfg.monthly, Math.max(cfg.ratePercent, 4), 40) / MAX_COINS);

    // ----- tree in a pot -----
    const potX = -0.14;
    const pot = new THREE.Mesh(
        new THREE.CylinderGeometry(0.055, 0.042, 0.06, 32),
        new THREE.MeshStandardMaterial({ color: 0xa8643a, roughness: 0.8 }));
    pot.position.set(potX, 0.03, 0);
    stage.root.add(pot);

    const tree = new THREE.Group();
    tree.position.set(potX, 0.058, 0);
    const trunk = new THREE.Mesh(
        new THREE.CylinderGeometry(0.008, 0.014, 0.16, 12),
        new THREE.MeshStandardMaterial({ color: 0x6b4a2f, roughness: 0.9 }));
    trunk.position.y = 0.08;
    tree.add(trunk);
    const leafMat = new THREE.MeshStandardMaterial({ color: 0x4f9a5b, roughness: 0.7, flatShading: true });
    [[0, 0.19, 0, 0.07], [-0.045, 0.16, 0.01, 0.05], [0.045, 0.165, -0.01, 0.052], [0, 0.235, 0, 0.048]].forEach(([x, y, z, r]) => {
        const leaf = new THREE.Mesh(new THREE.IcosahedronGeometry(r, 1), leafMat);
        leaf.position.set(x, y, z);
        tree.add(leaf);
    });
    stage.root.add(tree);

    const treeLabel = makeLabel('', '', 0.19);
    stage.root.add(treeLabel);

    // ----- coin stacks -----
    const COIN_H = 0.004;
    const coinGeo = new THREE.CylinderGeometry(0.028, 0.028, COIN_H, 28);
    function makeStack(x, color) {
        const mesh = new THREE.InstancedMesh(coinGeo, new THREE.MeshStandardMaterial({ color, metalness: 0.55, roughness: 0.35 }), MAX_COINS);
        const m = new THREE.Matrix4();
        for (let i = 0; i < MAX_COINS; i++) {
            // a slight wobble so it reads as a pile of coins, not a cylinder
            m.makeTranslation(x + Math.sin(i * 2.3) * 0.0025, COIN_H / 2 + i * COIN_H, Math.cos(i * 1.7) * 0.0025);
            mesh.setMatrixAt(i, m);
        }
        mesh.count = 0;
        stage.root.add(mesh);
        const label = makeLabel('', '', 0.13);
        stage.root.add(label);
        return { mesh, label, x, shown: 0, target: 0 };
    }
    const putIn = makeStack(0.04, 0xd9a440);
    const interest = makeStack(0.2, 0x58a868);

    // Coins pop on one at a time instead of jumping.
    stage.onFrame(dt => {
        [putIn, interest].forEach(s => {
            if (s.shown === s.target) return;
            const step = Math.max(1, Math.round(Math.abs(s.target - s.shown) * dt * 6));
            s.shown += s.target > s.shown ? Math.min(step, s.target - s.shown) : -Math.min(step, s.shown - s.target);
            s.mesh.count = s.shown;
        });
    });
    stage.onPick = () => { };

    // ----- controls -----
    const panel = document.createElement('div');
    panel.className = 'ar-panel';
    panel.innerHTML =
        '<label class="ar-slider"><span>Save every month</span><input type="range" data-k="monthly" min="10" max="1000" step="10" /><b data-v="monthly"></b></label>' +
        '<label class="ar-slider"><span>Interest per year</span><input type="range" data-k="rate" min="0" max="10" step="0.5" /><b data-v="rate"></b></label>' +
        '<label class="ar-slider"><span>Years</span><input type="range" data-k="years" min="1" max="40" step="1" /><b data-v="years"></b></label>' +
        '<p class="ar-readout" data-readout></p>' +
        '<div class="ar-actions">' +
        '<button type="button" class="btn btn--primary btn--sm" data-act="finish" disabled>I\'ve seen enough</button>' +
        '</div>';
    api.setControls(panel);

    const inputs = panel.querySelectorAll('input[type="range"]');
    const finishBtn = panel.querySelector('[data-act="finish"]');
    inputs.forEach(input => {
        input.value = state[input.dataset.k];
        input.oninput = () => {
            state[input.dataset.k] = +input.value;
            changes++;
            update();
        };
    });
    finishBtn.onclick = () => finish();

    function update() {
        const total = futureValue(state.monthly, state.rate, state.years);
        const paid = state.monthly * state.years * 12;
        const earned = Math.max(0, total - paid);

        panel.querySelector('[data-v="monthly"]').textContent = money(state.monthly);
        panel.querySelector('[data-v="rate"]').textContent = state.rate + '%';
        panel.querySelector('[data-v="years"]').textContent = state.years + (state.years === 1 ? ' year' : ' years');
        panel.querySelector('[data-readout]').innerHTML =
            'After ' + state.years + ' years: <strong>' + money(total) + '</strong><br />' +
            'You put in ' + money(paid) + ', interest added ' + money(earned) + '.';

        putIn.target = Math.min(MAX_COINS, Math.round(paid / unit));
        interest.target = Math.min(MAX_COINS, Math.round(earned / unit));
        putIn.label.userData.setText('You put in', money(paid));
        interest.label.userData.setText('Interest', money(earned));
        putIn.label.position.set(putIn.x, Math.max(putIn.target, 6) * COIN_H + 0.05, 0);
        interest.label.position.set(interest.x, Math.max(interest.target, 6) * COIN_H + 0.05, 0);

        const s = 0.45 + 0.75 * Math.min(1, state.years / 40);
        stage.animate(tree, { scale: new THREE.Vector3(s, s, s) }, 350);
        treeLabel.userData.setText('Year ' + state.years, money(total));
        treeLabel.position.set(potX, 0.035, 0.1); // in front of the pot, so it never grows out of view

        finishBtn.disabled = changes < 2;
        api.setInstruction(changes < 2
            ? 'Move the sliders and watch the tree and the coin stacks grow. Try a few different numbers of years.'
            : 'Notice how the green interest stack overtakes what you put in as the years go by.');
    }

    function finish() {
        if (done) return;
        done = true;
        const total = futureValue(state.monthly, state.rate, state.years);
        const paid = state.monthly * state.years * 12;
        const earned = Math.max(0, total - paid);
        const share = total > 0 ? Math.round(earned / total * 100) : 0;

        const feedback = [
            'Interest is ' + share + '% of the final ' + money(total) + '.'
        ];
        if (state.years + 10 <= 50) {
            const earlier = futureValue(state.monthly, state.rate, state.years + 10);
            feedback.push('Starting 10 years earlier (' + (state.years + 10) + ' years) would give ' + money(earlier) +
                ', ' + (earlier / Math.max(total, 1)).toFixed(1) + ' times as much.');
        }
        if (state.rate <= 3) feedback.push('At ' + state.rate + '% most of the money is what you saved yourself. Higher returns usually come with more risk.');

        api.finish({
            score: null,
            summary: money(state.monthly) + '/month at ' + state.rate + '% for ' + state.years + ' years grows to ' +
                money(total) + ' (' + money(paid) + ' put in, ' + money(earned) + ' interest).',
            feedback,
            detail: { monthly: state.monthly, ratePercent: state.rate, years: state.years, total: Math.round(total), paid, interest: Math.round(earned), sliderMoves: changes }
        });
    }

    function reset() {
        done = false;
        changes = 0;
        Object.assign(state, { monthly: cfg.monthly, rate: cfg.ratePercent, years: cfg.years });
        inputs.forEach(input => { input.value = state[input.dataset.k]; });
        update();
    }

    update();
    return { reset };
}
