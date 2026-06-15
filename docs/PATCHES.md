# wayscope — patch & feature sources

Curated upstream/staging patches and external projects to pull into wayscope.
Per house rule: **we take staging/unmerged patches too.** Fork/port the
reference 1:1 — never hand-roll what exists. Rig target: **desktop RTX 5090
(Blackwell) · NVIDIA Wayland · 55" OLED 4K@120 HDR · COSMIC.** No handheld.

Status legend: `[take]` queued to port · `[hold]` valuable, sequence later ·
`[done]` already merged on `gamescope-plus-nvidia`.

---

## A. Open / staging gamescope PRs (ValveSoftware/gamescope)

### NVIDIA / WSI / crash
- `[take]` **#2094** (OPEN, +10) — Fix Steam Remote Play black screen (Intel/NVIDIA) **+ inverted R/B colours on NVIDIA**. Direct NVIDIA color bug.
- `[take]` **#2209** (OPEN) — wlserver: fix use-after-free retiring a destroyed `gamescope_swapchain`. NVIDIA WSI crash.
- `[take]` **#2189** (OPEN) — rendervulkan: remove `HAVE_DRM` guard from `createDevice()`. NVIDIA/headless device creation.
- `[take]` **#2183** (OPEN) — layer: force bypass when requested format unsupported on fallback. WSI robustness.

### HDR / colour management
- `[take]` **#2148** (OPEN, +3) — **content-driven HDR output** (only enable HDR on HDR content). Port the compositor half; drop the Legion Go 2 script.
- `[hold]` **#2113** (DRAFT, +3) — migrate colour mgmt from AMD-specific DRM props to the **new generic KMS colour API**. Big, future-proofs NVIDIA colour. Watch + rebase when it matures.
- `[take]` **#2216** (OPEN) — DRMBackend: clear inherited CRTC colour when enabling a CRTC. Avoids stale colour pipeline.
- `[take]` **#2200** (OPEN) — colorspace overrides in `modes.cfg`. Per-display colour control (good for the Hisense EDID quirks).

### Scaling / sharpening / ReShade
- `[take]` **#740** (OPEN) — **bicubic downscaling** (the patch Bazzite issue #2295 asked for; clean 4K→1440p quality).
- `[take]` **#702** (OPEN) — enable FSR for **downscaling** (supersampling path).
- `[take]` **#2195** (OPEN) — reshade: update ReShade FX support to **v6.6.2** (pairs with the gamescope-plus ReShade port).
- `[take]` **#2191** (OPEN) — fix render order: **upscale first → ReShade at final res** (correctness for the ReShade path).

### General robustness
- `[take]` **#2215** (OPEN) — wlserver: don't freeze confined cursor on empty region.
- `[take]` **#2211** (OPEN) — steamcompmgr: don't reject same-app override candidates on pid mismatch.
- `[take]` **#2197** (OPEN) — runtime display selection in DRM backend (multi-output: TV + monitor).
- `[hold]` **#2185** (OPEN) — replace `-ffast-math` with `-funsafe-math-optimizations` (colour-math correctness; verify no perf regression).

## B. Closed VRR/latency PRs — **we take them anyway** (Kira's call)
- `[take]` **#2115** — steamcompmgr: throttle frame callbacks to output refresh with VRR.
- `[take]` **#1963** — WaylandBackend: enable VRR for `wp_presentation_v2` compositors.
- `[take]` **#1895** — steamcompmgr: fix VRR frame-limiter CPU usage.
- `[take]` **#1905** — add `Drain()` to `IWaitable` to fix FPS-limit-with-VRR jitter.
  > These overlap the planned gamescope-plus VRR-redzone work — fold them together.

## C. Merged foundations — verify we're not behind
- **#867** present-wait + presentation time · **#488** NVIDIA Image Scaling · **#454** NVIDIA Vulkan driver fixes · **#1892/#1463** FSR preemptive/inline upscaling. Diff `gamescope main` vs our branch and pull any we're missing.

---

## D. External projects (fork/port, NOT into the compositor unless noted)

| Project | What | Verdict | Altitude |
|---|---|---|---|
| `ValveSoftware/gamescope @ bfi-test` | Black Frame Insertion | **DO NOW** | compositor — port the branch |
| `ShadowBlip/gamescope-dbus` | DBus control daemon | **DO NOW** → rebrand `wayscope-dbus` | sidecar daemon + zbus client in cosmic-settings |
| `ChimeraOS/gamescope @ gamescope-plus` | ReShade iface, VRR tighten, clipboard, NV12 colour, magnifier crash fix | **planned** | hand-port (1104-commit divergent) |
| `expand1n/vkBasalt` (maint. fork of DadSchoorse) | SMAA/LUT post-fx | DO LATER | **launcher env toggle**, not wayscope code |
| `PancakeTAS/lsfg-vk`, `cdozdil/OptiScaler` | frame-gen / upscaler injectors | **REJECT** as pipeline; 5090 has native DLSS4 MFG. env toggle only if ever | game-level layer |
| `OpenGamingCollective/ScopeBuddy` | per-game profile manager | DO LATER | steal the **profile schema** into our launcher |
| `ChimeraOS/gamescope-session` (+ `-steam`) | full game-mode session | DO LATER (L) | optional greetd target; **keeps COSMIC + kms-hdr** |

---

## E. Prioritized build order (crew-vetted)

1. **NVIDIA present-correctness foundation** — explicit-sync (`linux-drm-syncobj-v1`) + `VK_KHR_present_wait`/`present_id` pacing on Blackwell. *Bedrock — BFI & VRR judder without it.* (gamescope `main` + PRs above) — **M**
2. **wayscope-dbus + live cosmic-settings control** — fork `gamescope-dbus`, zbus client in the Gaming page. Kills relaunch-to-apply. — **M**
3. **BFI port** (`bfi-test`) — gated vs HDR brightness, mutually exclusive with VRR. The OLED motion-clarity killer feature. — **M**
4. **Per-game profiles + env toggles** (vkBasalt/Reflex/SmoothMotion) surfaced in the Gaming page once #2 lands. — **S–M**
5. **Optional Big-Picture session** via `greetd` (separate seat/VT — COSMIC owns tty1). — **L**

**Rejected:** frame-gen injection into the pipeline (worse than native DLSS4 on a 5090); "gamescope session replaces kms-hdr" (it doesn't — you'd lose your DE).
