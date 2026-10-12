// Meowlet AR core: one three.js scene shown three ways.
//   3D mode      - in the page, rotated with mouse or finger (every device)
//   card mode    - image tracking with MindAR: the activity appears on the printed
//                  Meowlet card and follows it (any camera: laptops, iPhones, Android)
//   AR mode      - WebXR immersive-ar with hit testing: aim at a table, tap to place
//                  (Chrome on Android with ARCore)
// Scenes add their objects to stage.root, register tappable objects with
// stage.addPickable(), and receive taps through stage.onPick.
// Units are metres, so the activity is about 60 cm wide on a real table.

import * as THREE from 'three';
import { OrbitControls } from 'three/addons/OrbitControls.js';

export { THREE };

export async function arSupported() {
    try {
        return !!(window.isSecureContext && navigator.xr && await navigator.xr.isSessionSupported('immersive-ar'));
    } catch (e) {
        return false;
    }
}

export function cameraSupported() {
    return !!(window.isSecureContext && navigator.mediaDevices && navigator.mediaDevices.getUserMedia);
}

export function webglSupported() {
    try {
        const c = document.createElement('canvas');
        return !!(window.WebGLRenderingContext && (c.getContext('webgl2') || c.getContext('webgl')));
    } catch (e) {
        return false;
    }
}

const ease = t => 1 - Math.pow(1 - t, 3);

export class Stage {
    constructor(host) {
        this.host = host;
        this.mode = '3d';
        this.pickables = [];
        this.tweens = [];
        this.frameHandlers = [];
        this.onPick = null;      // (pickValue, object) => void
        this.onModeChange = null; // (mode) => void
        this.onPlaced = null;     // () => void, AR only

        const renderer = this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
        renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
        renderer.xr.enabled = true;
        host.appendChild(renderer.domElement);

        this.scene = new THREE.Scene();
        this.camera = new THREE.PerspectiveCamera(45, 1, 0.01, 30);
        this.camera.position.set(0, 0.5, 0.92);

        this.controls = new OrbitControls(this.camera, renderer.domElement);
        this.controls.target.set(0, 0.0, 0.1);
        this.controls.enableDamping = true;
        this.controls.enablePan = false;
        this.controls.minDistance = 0.35;
        this.controls.maxDistance = 3.2;
        this.controls.maxPolarAngle = 1.42;
        this.baseOffset = this.camera.position.clone().sub(this.controls.target);

        this.scene.add(new THREE.HemisphereLight(0xffffff, 0x5a4a3a, 2.2));
        const sun = new THREE.DirectionalLight(0xffffff, 1.6);
        sun.position.set(0.6, 1.2, 0.8);
        this.scene.add(sun);

        // The table top in 3D mode; in AR the real table takes its place.
        this.floor = new THREE.Mesh(
            new THREE.CircleGeometry(0.48, 64),
            new THREE.MeshStandardMaterial({ color: 0xe8dcc6, roughness: 0.95 }));
        this.floor.rotation.x = -Math.PI / 2;
        this.floor.position.y = -0.001;
        this.scene.add(this.floor);

        this.root = new THREE.Group();
        this.scene.add(this.root);

        // AR placement ring
        this.reticle = new THREE.Mesh(
            new THREE.RingGeometry(0.06, 0.08, 40).rotateX(-Math.PI / 2),
            new THREE.MeshBasicMaterial({ color: 0xffffff }));
        this.reticle.matrixAutoUpdate = false;
        this.reticle.visible = false;
        this.scene.add(this.reticle);

        this.raycaster = new THREE.Raycaster();
        this.clock = new THREE.Clock();

        this._wirePointer();
        this._resize();
        if (window.ResizeObserver) new ResizeObserver(() => this._resize()).observe(host);
        else window.addEventListener('resize', () => this._resize());

        renderer.setAnimationLoop((time, frame) => this._tick(frame));
    }

    // ---------- scene helpers ----------

    addPickable(object, value) {
        object.userData.pick = value;
        this.pickables.push(object);
    }

    removePickable(object) {
        const i = this.pickables.indexOf(object);
        if (i >= 0) this.pickables.splice(i, 1);
    }

    // Where the 3D-mode camera starts and what it circles around.
    frame(target, position) {
        this.controls.target.set(target[0], target[1], target[2]);
        this.camera.position.set(position[0], position[1], position[2]);
        this.baseOffset = this.camera.position.clone().sub(this.controls.target);
        this._resize();
    }

    onFrame(fn) {
        this.frameHandlers.push(fn);
    }

    // Move/scale/rotate an object smoothly. to = { position, scale, rotation } (Vector3 / Euler values).
    animate(object, to, ms = 450) {
        this.tweens = this.tweens.filter(t => t.object !== object);
        const from = {
            position: object.position.clone(),
            scale: object.scale.clone(),
            rotation: new THREE.Vector3(object.rotation.x, object.rotation.y, object.rotation.z)
        };
        this.tweens.push({ object, from, to, start: performance.now(), ms });
    }

    // ---------- image tracking (Meowlet card) ----------
    // MindAR finds the printed card in the camera picture and reports its pose
    // every frame. The activity is attached to the card: hidden until the card is
    // seen, then it sits on the card and follows it as the card moves or tilts.
    // Works with any camera (laptop webcam, iPhone, Android) in a secure context.

    async startTracking({ Controller, target, onFound, onLost, onStatus }) {
        if (this.mode === 'ar') throw new Error('Leave AR first');
        const status = onStatus || (() => { });

        status('Starting the camera...');
        const stream = await navigator.mediaDevices.getUserMedia({
            audio: false,
            video: { facingMode: { ideal: 'environment' }, width: { ideal: 1280 }, height: { ideal: 720 } }
        });
        const video = document.createElement('video');
        video.className = 'ar-video';
        video.setAttribute('autoplay', '');
        video.setAttribute('muted', '');
        video.setAttribute('playsinline', '');
        video.muted = true;
        video.srcObject = stream;
        await new Promise(resolve => video.addEventListener('loadedmetadata', resolve, { once: true }));
        video.setAttribute('width', video.videoWidth);
        video.setAttribute('height', video.videoHeight);
        this.host.insertBefore(video, this.renderer.domElement);
        try { await video.play(); } catch (e) { /* muted inline video may autoplay */ }
        this.video = video;
        this.cameraStream = stream;

        try {
            status('Loading the card tracker...');
            const controller = new Controller({
                inputWidth: video.videoWidth,
                inputHeight: video.videoHeight,
                maxTrack: 1,
                onUpdate: data => this._trackUpdate(data)
            });
            this.tracker = controller;

            // target = { buffer } (compiled .mind data) or { url }
            const added = target.buffer
                ? controller.addImageTargetsFromBuffer(target.buffer)
                : await controller.addImageTargets(target.url);
            const [w, h] = added.dimensions[0];

            // Card space -> world: centre of the card, 1 unit = card width (same as MindAR's three.js wrapper).
            this.postMatrix = new THREE.Matrix4().compose(
                new THREE.Vector3(w / 2, w / 2 + (h - w) / 2, 0),
                new THREE.Quaternion(),
                new THREE.Vector3(w, w, w));

            // The anchor follows the card. Inside it the activity stands up out of the card
            // (scene "up" = the card's normal) and is scaled so ~60 cm of scene spans ~1.5 cards.
            this.anchor = new THREE.Group();
            this.anchor.matrixAutoUpdate = false;
            this.anchor.visible = false;
            this.scene.add(this.anchor);
            this.anchor.add(this.root);
            this.root.position.set(0, 0, 0);
            this.root.rotation.set(Math.PI / 2, 0, 0);
            this.root.scale.setScalar(2.5);

            this.floor.visible = false;
            this.controls.enabled = false;
            this.camera.position.set(0, 0, 0);
            this.camera.quaternion.identity();
            this._onFound = onFound;
            this._onLost = onLost;
            this.cardVisible = false;
            this._setMode('tracking');
            this._resize();

            status('Warming up...');
            await controller.dummyRun(video);
            controller.processVideo(video);
            status(null);
        } catch (e) {
            this.stopTracking();
            throw e;
        }
    }

    stopTracking() {
        if (this.tracker) {
            try { this.tracker.stopProcessVideo(); } catch (e) { }
            try { this.tracker.dispose(); } catch (e) { }
            this.tracker = null;
        }
        if (this.cameraStream) this.cameraStream.getTracks().forEach(t => t.stop());
        if (this.video) this.video.remove();
        this.cameraStream = null;
        this.video = null;

        if (this.anchor) {
            this.scene.add(this.root);
            this.scene.remove(this.anchor);
            this.anchor = null;
        }
        this.root.position.set(0, 0, 0);
        this.root.rotation.set(0, 0, 0);
        this.root.scale.setScalar(1);
        this.root.visible = true;
        this.floor.visible = true;
        this.controls.enabled = true;
        this.camera.fov = 45;
        this.camera.near = 0.01;
        this.camera.far = 30;
        this.camera.quaternion.identity();
        if (this.mode === 'tracking') this._setMode('3d');
        this._resize();
        this.camera.lookAt(this.controls.target);
    }

    _trackUpdate(data) {
        if (data.type !== 'updateMatrix' || !this.anchor) return;
        const found = data.worldMatrix !== null;
        if (found) {
            this.anchor.matrix.fromArray(data.worldMatrix).multiply(this.postMatrix);
            this.anchor.matrixWorldNeedsUpdate = true;
        }
        this.anchor.visible = found;
        if (found && !this.cardVisible) {
            this.cardVisible = true;
            if (this._onFound) this._onFound();
        } else if (!found && this.cardVisible) {
            this.cardVisible = false;
            if (this._onLost) this._onLost();
        }
    }

    // Same maths as MindAR's three.js wrapper: video covers the stage, and the
    // camera's field of view matches the tracker's projection.
    _trackResize() {
        const video = this.video, host = this.host, tracker = this.tracker;
        const cw = host.clientWidth || 1, ch = host.clientHeight || 1;
        const videoRatio = video.videoWidth / video.videoHeight;
        const hostRatio = cw / ch;
        let vw, vh;
        if (videoRatio > hostRatio) { vh = ch; vw = vh * videoRatio; } else { vw = cw; vh = vw / videoRatio; }
        video.style.width = vw + 'px';
        video.style.height = vh + 'px';
        video.style.left = (-(vw - cw) / 2) + 'px';
        video.style.top = (-(vh - ch) / 2) + 'px';

        const proj = tracker.getProjectionMatrix();
        const inputRatio = tracker.inputWidth / tracker.inputHeight;
        const displayHeight = inputRatio > hostRatio ? ch : cw / tracker.inputWidth * tracker.inputHeight;
        const fovAdjust = ch / displayHeight;
        this.camera.fov = 2 * Math.atan(1 / proj[5] * fovAdjust) * 180 / Math.PI;
        this.camera.near = proj[14] / (proj[10] - 1.0);
        this.camera.far = proj[14] / (proj[10] + 1.0);
        this.camera.aspect = cw / ch;
        this.camera.updateProjectionMatrix();
        this.renderer.setSize(cw, ch, false);
    }

    // ---------- AR ----------

    async startAR(overlayRoot) {
        if (this.mode === 'tracking') this.stopTracking();
        const session = await navigator.xr.requestSession('immersive-ar', {
            requiredFeatures: ['hit-test'],
            optionalFeatures: ['dom-overlay'],
            domOverlay: { root: overlayRoot }
        });

        this._savedCamera = this.camera.position.clone();
        this.renderer.xr.setReferenceSpaceType('local');
        await this.renderer.xr.setSession(session);

        const viewer = await session.requestReferenceSpace('viewer');
        this.hitSource = await session.requestHitTestSource({ space: viewer });

        this.session = session;
        this.placed = false;
        this.root.visible = false;
        this.floor.visible = false;
        this.controls.enabled = false;
        this._setMode('ar');

        session.addEventListener('select', e => this._xrSelect(e));
        session.addEventListener('end', () => this._xrEnded());
    }

    endAR() {
        if (this.session) this.session.end();
    }

    _xrEnded() {
        if (this.hitSource) { this.hitSource.cancel(); this.hitSource = null; }
        this.session = null;
        this.reticle.visible = false;
        this.root.visible = true;
        this.root.position.set(0, 0, 0);
        this.root.rotation.set(0, 0, 0);
        this.floor.visible = true;
        this.controls.enabled = true;
        if (this._savedCamera) this.camera.position.copy(this._savedCamera);
        this.camera.lookAt(this.controls.target);
        this._setMode('3d');
        this._resize();
    }

    _xrFrame(frame) {
        if (this.placed || !this.hitSource) return;
        const ref = this.renderer.xr.getReferenceSpace();
        const hits = frame.getHitTestResults(this.hitSource);
        if (hits.length) {
            const pose = hits[0].getPose(ref);
            this.reticle.visible = !!pose;
            if (pose) this.reticle.matrix.fromArray(pose.transform.matrix);
        } else {
            this.reticle.visible = false;
        }
    }

    _xrSelect(event) {
        if (!this.placed) {
            if (!this.reticle.visible) return;
            // Put the activity on the surface, turned to face the learner.
            this.root.position.setFromMatrixPosition(this.reticle.matrix);
            const eye = new THREE.Vector3();
            this.camera.getWorldPosition(eye);
            this.root.rotation.set(0, Math.atan2(eye.x - this.root.position.x, eye.z - this.root.position.z), 0);
            this.root.visible = true;
            this.reticle.visible = false;
            this.placed = true;
            if (this.hitSource) { this.hitSource.cancel(); this.hitSource = null; }
            if (this.onPlaced) this.onPlaced();
            return;
        }

        const ref = this.renderer.xr.getReferenceSpace();
        const pose = event.frame && event.frame.getPose(event.inputSource.targetRaySpace, ref);
        if (!pose) return;
        const m = new THREE.Matrix4().fromArray(pose.transform.matrix);
        const origin = new THREE.Vector3().setFromMatrixPosition(m);
        const direction = new THREE.Vector3(0, 0, -1).transformDirection(m);
        this.raycaster.set(origin, direction);
        this._pick();
    }

    // ---------- internals ----------

    _setMode(mode) {
        this.mode = mode;
        if (this.onModeChange) this.onModeChange(mode);
    }

    _wirePointer() {
        const el = this.renderer.domElement;
        let down = null;
        el.addEventListener('pointerdown', e => { down = { x: e.clientX, y: e.clientY }; });
        el.addEventListener('pointerup', e => {
            if (!down || this.mode === 'ar') return;
            if (this.mode === 'tracking' && !this.cardVisible) { down = null; return; } // nothing to tap until the card is seen
            const moved = Math.hypot(e.clientX - down.x, e.clientY - down.y);
            down = null;
            if (moved > 8) return; // that was a drag to rotate
            const rect = el.getBoundingClientRect();
            const ndc = new THREE.Vector2(
                ((e.clientX - rect.left) / rect.width) * 2 - 1,
                -((e.clientY - rect.top) / rect.height) * 2 + 1);
            this.raycaster.setFromCamera(ndc, this.camera);
            this._pick();
        });
    }

    _pick() {
        const hits = this.raycaster.intersectObjects(this.pickables, true);
        for (const hit of hits) {
            let o = hit.object;
            while (o && o.userData.pick === undefined) o = o.parent;
            if (o && o.visible !== false) {
                if (this.onPick) this.onPick(o.userData.pick, o);
                return;
            }
        }
        if (this.onPick) this.onPick(null, null);
    }

    _resize() {
        if (this.renderer.xr.isPresenting) return;
        if (this.mode === 'tracking' && this.tracker && this.video) { this._trackResize(); return; }
        const w = this.host.clientWidth || 1, h = this.host.clientHeight || 1;
        this.renderer.setSize(w, h, false);
        this.camera.aspect = w / h;
        this.camera.updateProjectionMatrix();
        // Scenes are framed for a wide view; on a tall, narrow phone screen pull
        // the camera back so the whole activity still fits side to side.
        const fit = Math.max(1, 1.45 / this.camera.aspect);
        this.camera.position.copy(this.controls.target).addScaledVector(this.baseOffset, fit);
        this.controls.update();
    }

    _tick(frame) {
        const dt = Math.min(this.clock.getDelta(), 0.1);
        if (frame) this._xrFrame(frame);
        else if (this.mode !== 'tracking') this.controls.update();

        const now = performance.now();
        this.tweens = this.tweens.filter(t => {
            const k = ease(Math.min(1, (now - t.start) / t.ms));
            if (t.to.position) t.object.position.lerpVectors(t.from.position, t.to.position, k);
            if (t.to.scale) t.object.scale.lerpVectors(t.from.scale, t.to.scale, k);
            if (t.to.rotation) {
                const r = new THREE.Vector3().lerpVectors(t.from.rotation, t.to.rotation, k);
                t.object.rotation.set(r.x, r.y, r.z);
            }
            return k < 1;
        });

        for (const fn of this.frameHandlers) fn(dt);
        this.renderer.render(this.scene, this.camera);
    }
}

// ---------- canvas-drawn text ----------

function roundRect(ctx, x, y, w, h, r) {
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.arcTo(x + w, y, x + w, y + h, r);
    ctx.arcTo(x + w, y + h, x, y + h, r);
    ctx.arcTo(x, y + h, x, y, r);
    ctx.arcTo(x, y, x + w, y, r);
    ctx.closePath();
}

const FONT = '"Segoe UI", system-ui, -apple-system, Roboto, sans-serif';

// A floating label that always faces the camera. label.userData.setText(line1, line2) redraws it.
export function makeLabel(line1, line2 = '', width = 0.15) {
    const canvas = document.createElement('canvas');
    canvas.width = 512;
    canvas.height = 192;
    const texture = new THREE.CanvasTexture(canvas);
    texture.colorSpace = THREE.SRGBColorSpace;
    const sprite = new THREE.Sprite(new THREE.SpriteMaterial({ map: texture, transparent: true, depthWrite: false, depthTest: false }));
    sprite.scale.set(width, width * 192 / 512, 1);
    sprite.renderOrder = 10;

    sprite.userData.setText = (a, b = '') => {
        const ctx = canvas.getContext('2d');
        ctx.clearRect(0, 0, 512, 192);
        ctx.fillStyle = 'rgba(29, 24, 18, 0.86)';
        roundRect(ctx, 8, 8, 496, 176, 40);
        ctx.fill();
        ctx.fillStyle = '#ffffff';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        if (b) {
            ctx.font = '600 58px ' + FONT;
            ctx.fillText(a, 256, 68, 470);
            ctx.font = '400 46px ' + FONT;
            ctx.fillStyle = '#f0dcc6';
            ctx.fillText(b, 256, 134, 470);
        } else {
            ctx.font = '600 64px ' + FONT;
            ctx.fillText(a, 256, 96, 470);
        }
        texture.needsUpdate = true;
    };
    sprite.userData.setText(line1, line2);
    return sprite;
}

// A flat expense card texture: coloured strip, name, amount.
export function makeCardTexture(name, amount, accent = '#b9703c') {
    const canvas = document.createElement('canvas');
    canvas.width = 512;
    canvas.height = 320;
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = '#fffaf2';
    roundRect(ctx, 0, 0, 512, 320, 36);
    ctx.fill();
    ctx.fillStyle = accent;
    roundRect(ctx, 0, 0, 512, 56, 28);
    ctx.fill();
    ctx.fillRect(0, 28, 512, 28);
    ctx.fillStyle = '#241d15';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.font = '600 64px ' + FONT;
    ctx.fillText(name, 256, 150, 470);
    ctx.font = '400 56px ' + FONT;
    ctx.fillStyle = '#6d6053';
    ctx.fillText(amount, 256, 238, 470);
    const texture = new THREE.CanvasTexture(canvas);
    texture.colorSpace = THREE.SRGBColorSpace;
    texture.anisotropy = 4;
    return texture;
}

export function formatMoney(value, currency = 'RM') {
    return currency + Math.round(value).toLocaleString('en-MY');
}
