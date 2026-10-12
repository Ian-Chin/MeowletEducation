// Budget jars: sort a month of spending into Needs, Wants and Savings,
// then compare the split with the 50/30/20 guide.
// Tap a card, then tap a jar. Tap a jar with no card picked to take its last card back out.
//
// Lesson settings (CourseLessons.ARConfig), all optional:
//   { "currency": "RM", "income": 3000,
//     "cards": [ { "name": "Rent", "amount": 900, "jar": "needs" }, ... ] }

import { THREE, makeLabel, makeCardTexture, formatMoney } from './ar-core.js';

const JARS = [
    { key: 'needs', name: 'Needs', target: 50, color: 0xc77b3e, css: '#c77b3e' },
    { key: 'wants', name: 'Wants', target: 30, color: 0x5f86b0, css: '#5f86b0' },
    { key: 'savings', name: 'Savings', target: 20, color: 0x4f9a5b, css: '#4f9a5b' }
];

const DEFAULTS = {
    currency: 'RM',
    income: 3000,
    cards: [
        { name: 'Rent', amount: 900, jar: 'needs' },
        { name: 'Groceries', amount: 400, jar: 'needs' },
        { name: 'Transport', amount: 250, jar: 'needs' },
        { name: 'Phone + bills', amount: 150, jar: 'needs' },
        { name: 'Eating out', amount: 300, jar: 'wants' },
        { name: 'Shopping', amount: 250, jar: 'wants' },
        { name: 'Streaming', amount: 50, jar: 'wants' },
        { name: 'Emergency fund', amount: 400, jar: 'savings' },
        { name: 'Investing', amount: 300, jar: 'savings' }
    ]
};

function settings(config) {
    const cfg = Object.assign({}, DEFAULTS, config || {});
    const cards = (Array.isArray(cfg.cards) ? cfg.cards : [])
        .filter(c => c && c.name && +c.amount > 0 && JARS.some(j => j.key === c.jar))
        .slice(0, 12);
    cfg.cards = cards.length >= 2 ? cards : DEFAULTS.cards;
    const total = cfg.cards.reduce((s, c) => s + (+c.amount), 0);
    cfg.income = +cfg.income > 0 ? +cfg.income : total;
    return cfg;
}

export function create(stage, config, api) {
    const cfg = settings(config);
    stage.frame([0, -0.025, 0.12], [0, 0.5, 0.95]);
    const money = v => formatMoney(v, cfg.currency);

    const JAR_H = 0.16, JAR_R = 0.065, FILL_MAX = 0.145;
    const jars = {};

    // ----- jars -----
    JARS.forEach((def, i) => {
        const group = new THREE.Group();
        group.position.set((i - 1) * 0.2, 0, -0.06);

        const glass = new THREE.Mesh(
            new THREE.CylinderGeometry(JAR_R, JAR_R * 0.92, JAR_H, 40, 1, true),
            new THREE.MeshStandardMaterial({ color: 0xffffff, transparent: true, opacity: 0.3, roughness: 0.08, side: THREE.DoubleSide, depthWrite: false }));
        glass.position.y = JAR_H / 2;
        group.add(glass);

        const rim = new THREE.Mesh(
            new THREE.TorusGeometry(JAR_R, 0.004, 8, 40),
            new THREE.MeshStandardMaterial({ color: def.color, roughness: 0.4 }));
        rim.rotation.x = Math.PI / 2;
        rim.position.y = JAR_H;
        group.add(rim);

        const base = new THREE.Mesh(
            new THREE.CylinderGeometry(JAR_R * 0.92, JAR_R * 0.92, 0.004, 40),
            new THREE.MeshStandardMaterial({ color: 0xf4efe6, transparent: true, opacity: 0.6, roughness: 0.2 }));
        base.position.y = 0.002;
        group.add(base);

        // The fill shows how much of the income has gone into this jar.
        const fill = new THREE.Mesh(
            new THREE.CylinderGeometry(JAR_R * 0.86, JAR_R * 0.82, 1, 40),
            new THREE.MeshStandardMaterial({ color: def.color, transparent: true, opacity: 0.75, roughness: 0.6 }));
        fill.scale.y = 0.0001;
        fill.visible = false;
        fill.position.y = 0.006;
        group.add(fill);

        // A faint ring marks the target level (50 / 30 / 20 % of income).
        const mark = new THREE.Mesh(
            new THREE.TorusGeometry(JAR_R * 1.02, 0.0018, 6, 40),
            new THREE.MeshBasicMaterial({ color: 0xffffff, transparent: true, opacity: 0.85 }));
        mark.rotation.x = Math.PI / 2;
        mark.position.y = 0.006 + FILL_MAX * def.target / 100;
        group.add(mark);

        const label = makeLabel(def.name, '0% of ' + def.target + '%', 0.16);
        label.position.y = JAR_H + 0.06;
        group.add(label);

        stage.root.add(group);
        stage.addPickable(group, { type: 'jar', key: def.key });
        jars[def.key] = { def, group, fill, label, glass };
    });

    // ----- cards -----
    const perRow = Math.min(5, Math.ceil(cfg.cards.length / 2));
    const cards = cfg.cards.map((c, i) => {
        const row = Math.floor(i / perRow), col = i % perRow;
        const inRow = Math.min(perRow, cfg.cards.length - row * perRow);
        const home = new THREE.Vector3((col - (inRow - 1) / 2) * 0.108, 0.012, 0.14 + row * 0.085);

        const mesh = new THREE.Mesh(
            new THREE.PlaneGeometry(0.096, 0.06),
            new THREE.MeshStandardMaterial({ map: makeCardTexture(c.name, money(+c.amount)), roughness: 0.7, side: THREE.DoubleSide }));
        // Lying on the table, tilted up a little towards the learner so it's readable.
        const homeRot = new THREE.Vector3(-Math.PI / 2 + 0.55, 0, 0);
        mesh.position.copy(home);
        mesh.rotation.set(homeRot.x, homeRot.y, homeRot.z);
        stage.root.add(mesh);

        const card = { index: i, data: c, mesh, home, homeRot, jar: null };
        stage.addPickable(mesh, { type: 'card', index: i });
        return card;
    });

    let selected = null;

    // ----- controls (HTML panel) -----
    const panel = document.createElement('div');
    panel.className = 'ar-panel';
    panel.innerHTML =
        '<div class="ar-split">' +
        JARS.map(j =>
            '<div class="ar-split__row"><span class="ar-split__name"><i style="background:' + j.css + '"></i>' + j.name + '</span>' +
            '<span class="ar-split__bar"><b data-bar="' + j.key + '" style="background:' + j.css + '"></b><u style="left:' + j.target + '%"></u></span>' +
            '<span class="ar-split__pct" data-pct="' + j.key + '">0%</span></div>').join('') +
        '</div>' +
        '<div class="ar-actions">' +
        '<button type="button" class="btn btn--ghost btn--sm" data-act="reset">Start over</button>' +
        '<button type="button" class="btn btn--primary btn--sm" data-act="finish" disabled>Check my budget</button>' +
        '</div>';
    api.setControls(panel);

    const finishBtn = panel.querySelector('[data-act="finish"]');
    panel.querySelector('[data-act="reset"]').onclick = () => reset();
    finishBtn.onclick = () => finish();

    // ----- behaviour -----
    function totals() {
        const sum = { needs: 0, wants: 0, savings: 0 };
        cards.forEach(c => { if (c.jar) sum[c.jar] += +c.data.amount; });
        return sum;
    }

    function refresh() {
        const sum = totals();
        JARS.forEach(j => {
            const pct = sum[j.key] / cfg.income * 100;
            const jar = jars[j.key];
            const h = Math.max(0.0001, Math.min(1.25, pct / 100) * FILL_MAX);
            jar.fill.visible = sum[j.key] > 0;
            stage.animate(jar.fill, { scale: new THREE.Vector3(1, h, 1), position: new THREE.Vector3(0, 0.006 + h / 2, 0) }, 400);
            jar.label.userData.setText(j.name, Math.round(pct) + '% of ' + j.target + '%');
            panel.querySelector('[data-bar="' + j.key + '"]').style.width = Math.min(100, pct) + '%';
            panel.querySelector('[data-pct="' + j.key + '"]').textContent = Math.round(pct) + '%';
        });
        const left = cards.filter(c => !c.jar).length;
        finishBtn.disabled = left > 0;
        api.setInstruction(left > 0
            ? (selected ? 'Now tap the jar it belongs in.' : 'Tap an expense card, then tap a jar. ' + left + ' of ' + cards.length + ' cards left.')
            : 'All sorted. Tap "Check my budget" to see how you did.');
    }

    function highlight(card, on) {
        card.mesh.material.emissive = new THREE.Color(on ? 0x553311 : 0x000000);
        const lift = card.home.clone();
        if (on) lift.y += 0.03;
        stage.animate(card.mesh, { position: lift, scale: new THREE.Vector3(on ? 1.12 : 1, on ? 1.12 : 1, 1) }, 220);
    }

    function stackInJar(key) {
        // Re-stack the cards in a jar as small chips, in the order they arrived.
        const inJar = cards.filter(c => c.jar === key);
        const jar = jars[key].group.position;
        inJar.forEach((c, n) => {
            stage.animate(c.mesh, {
                position: new THREE.Vector3(jar.x + (n % 2 ? 0.012 : -0.012), 0.02 + n * 0.014, jar.z),
                rotation: new THREE.Vector3(-Math.PI / 2, 0, (n % 3 - 1) * 0.35),
                scale: new THREE.Vector3(0.6, 0.6, 1)
            }, 500);
        });
    }

    function sendHome(card) {
        const from = card.jar;
        card.jar = null;
        stage.animate(card.mesh, { position: card.home, rotation: card.homeRot, scale: new THREE.Vector3(1, 1, 1) }, 450);
        if (from) stackInJar(from);
    }

    stage.onPick = pick => {
        if (done) return;
        if (!pick) return;

        if (pick.type === 'card') {
            const card = cards[pick.index];
            if (card.jar) { sendHome(card); refresh(); return; }  // take it back out
            if (selected === card) { highlight(card, false); selected = null; refresh(); return; }
            if (selected) highlight(selected, false);
            selected = card;
            highlight(card, true);
            refresh();
            return;
        }

        if (pick.type === 'jar') {
            if (!selected) {
                // Tapping a jar with no card picked takes its last card back out.
                const inJar = cards.filter(c => c.jar === pick.key);
                if (inJar.length) { sendHome(inJar[inJar.length - 1]); refresh(); }
                else api.setInstruction('Pick an expense card first, then tap a jar.');
                return;
            }
            const card = selected;
            selected = null;
            card.mesh.material.emissive = new THREE.Color(0x000000);
            card.jar = pick.key;
            stackInJar(pick.key);
            refresh();
        }
    };

    let done = false;

    function finish() {
        if (cards.some(c => !c.jar)) return;
        done = true;
        const sum = totals();
        const pct = {};
        JARS.forEach(j => { pct[j.key] = Math.round(sum[j.key] / cfg.income * 100); });
        const wrong = cards.filter(c => c.jar !== c.data.jar);
        const correct = cards.length - wrong.length;

        const feedback = [];
        wrong.slice(0, 3).forEach(c => {
            const right = JARS.find(j => j.key === c.data.jar).name;
            feedback.push('"' + c.data.name + '" usually belongs in ' + right + '.');
        });
        if (wrong.length > 3) feedback.push('...and ' + (wrong.length - 3) + ' more card(s) in a different jar than usual.');

        // Judge the budget itself using the tutor's intended jars, not the learner's guesses.
        const real = { needs: 0, wants: 0, savings: 0 };
        cards.forEach(c => { real[c.data.jar] += +c.data.amount; });
        const rp = k => Math.round(real[k] / cfg.income * 100);
        if (rp('needs') > 55) feedback.push('Needs take ' + rp('needs') + '% of income, above the 50% guide. Housing and transport are usually where to save.');
        if (rp('wants') > 35) feedback.push('Wants take ' + rp('wants') + '%. Trimming eating out or shopping would free money for savings.');
        if (rp('savings') < 15) feedback.push('Only ' + rp('savings') + '% goes to savings. Saving on payday ("pay yourself first") helps reach 20%.');
        else if (rp('savings') >= 20) feedback.push('This budget saves ' + rp('savings') + '% of income, meeting the 20% guide.');

        api.finish({
            score: Math.round(correct / cards.length * 100),
            summary: correct + ' of ' + cards.length + ' cards in the right jar. Split ' +
                pct.needs + ' / ' + pct.wants + ' / ' + pct.savings + ' (guide 50 / 30 / 20).',
            feedback,
            detail: {
                income: cfg.income,
                split: pct,
                cards: cards.map(c => ({ name: c.data.name, amount: +c.data.amount, chosen: c.jar, expected: c.data.jar }))
            }
        });
    }

    function reset() {
        done = false;
        if (selected) highlight(selected, false);
        selected = null;
        cards.forEach(c => {
            c.jar = null;
            c.mesh.material.emissive = new THREE.Color(0x000000);
            stage.animate(c.mesh, { position: c.home, rotation: c.homeRot, scale: new THREE.Vector3(1, 1, 1) }, 400);
        });
        refresh();
    }

    refresh();
    return { reset };
}
