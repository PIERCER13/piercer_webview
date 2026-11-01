<div align="center">

# 🌐 piercer_webview

**Open any website inside GTA V, right on your FiveM server.**

A lightweight, good-looking and 100% configurable in-game browser that works on **any framework**.
Store, staff panel, whitelist form, ranking, wiki, map… if it has a link, it opens in the game.

![FiveM](https://img.shields.io/badge/FiveM-resource-F40552?style=for-the-badge)
![Frameworks](https://img.shields.io/badge/ESX%20%C2%B7%20QBCore%20%C2%B7%20Qbox%20%C2%B7%20vRP%20%C2%B7%20standalone-2b2b2b?style=for-the-badge)
![Lua](https://img.shields.io/badge/Lua-5.4-000080?style=for-the-badge&logo=lua&logoColor=white)
[![Discord](https://img.shields.io/badge/Discord-join-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/jZ3vTmdjU7)

[![Ler em Português](https://img.shields.io/badge/Ler%20em%20Portugu%C3%AAs-5865F2?style=for-the-badge&logo=googletranslate&logoColor=white)](README.pt-BR.md)

</div>

---

## 🎯 What it's for

Many servers keep important things **outside the game**: VIP store, staff panel, whitelist form, rules, ranking, map…
Normally the player has to minimize GTA, open a browser, find the link and come back. That breaks immersion, and a lot of people give up halfway.

**piercer_webview** solves it: the player types a command (or presses a key) and the site opens **in a window on top of the game**, without leaving the server.
When they're done, they press **ESC** and go right back to playing.

**Use cases:**

| Site | How it looks in-game |
|---|---|
| 🛒 VIP / coins store | `/store` opens the store already showing the player's ID to paste at checkout |
| 📝 Whitelist / form | `/whitelist` opens the form with ID and name pre-filled via URL |
| 🛡️ Staff panel | `/panel` only opens for players with admin permission |
| 📖 Rules / wiki | `/rules` opens the server rules for anyone |
| 🏆 Ranking / stats | `/ranking` with a hotkey (e.g. `F7`) |
| 🗺️ Map, radio, menu, catalog… | Any page with a link (the ones that block iframes open via DUI) |

## 🔧 How it works

1. **The player opens it**: types the configured command (e.g. `/store`) or presses the hotkey.
2. **The server checks**: through [framezero_bridge](https://github.com/PIERCER13/framezero_bridge), `server.lua` gets the **character ID** from your framework and, if you set `Config.perms`, checks whether they have any of the permissions. If not, the access-denied notification shows and nothing opens.
3. **The window appears**: `client.lua` frees the mouse (`SetNuiFocus`) and tells the interface (NUI) to open. The NUI loads your site inside an **iframe**, with the title, color and ID you configured. If the site refuses iframes, it opens via **DUI** in the same spot (see [Sites that block iframes](#-sites-that-block-iframes-dui-mode)).
4. **(Optional) The site receives the data**: with `Config.sendParams = true`, the link opens as `yoursite.com/?id=123&name=John`, and the site can use that to fill fields automatically.
5. **The player closes it**: ESC or the ✕ button close the window and give control back to the game. When reopened, the page **continues where it left off** (no lost login or scroll). To refresh, just click ↻.

> Everything is controlled by **a single file**: [`config.lua`](config.lua). You don't need to know how to program to use it.

## ✨ What it does

- 🖥️ **Opens a site in a window** inside the game (iframe via NUI), with a dimmed background and an entry animation.
- 🛟 **Opens even sites that block iframes** (YouTube, GitBook, Google…): it detects the block on startup and falls back to **DUI** on its own.
- 🔗 **Fixes known links**: YouTube becomes `/embed/` and Google gets `igu=1`, so they open in an iframe with keyboard support.
- 🧩 **Multi-framework**: ESX, QBCore, Qbox, vRP, vRPex, Creative or standalone, without changing a single line of code.
- ⌨️ **Configurable command and key**: the player can still change the key in *Settings › Key Bindings › FiveM*.
- 🔒 **Permission restriction**: leave it open to everyone or only for `admin`, `police`, `vip`…
- 🪪 **Shows the character ID** at the top with a **copy** button, great for sites that ask for the player's ID.
- 🔗 **Sends `id` and `name` in the URL** (`?id=123&name=John`) so the site can identify the player automatically.
- 🎨 **Customizable title and accent color**, to match your server's identity.
- 🔄 **Reload** button, close with **ESC**, and the page **doesn't reload** every time you reopen it (keeps login, scroll, etc.).
- 📦 **Reusable template**: need 3 sites? Copy the folder 3 times and change only `config.lua`.

## 📋 Requirements

| Requirement | Note |
|---|---|
| **FiveM** server | Any recent artifact |
| **[framezero_bridge](https://github.com/PIERCER13/framezero_bridge)** | Detects your framework on its own and handles ID, name, permission and notifications |

## 🚀 Installation

1. Install **framezero_bridge** in `resources/`. The folder must be named exactly `framezero_bridge`.
2. Download this repository (**Code › Download ZIP**) or clone it:
   ```bash
   git clone https://github.com/PIERCER13/piercer_webview.git
   ```
3. Put the `piercer_webview` folder in your server's `resources/`.
4. Edit [`config.lua`](config.lua) (at least `Config.url` and `Config.command`).
5. In `server.cfg`, the order is: **framework → bridge → webview**:
   ```cfg
   ensure vrp              # or es_extended, qb-core, qbx_core... (skip if standalone)
   ensure framezero_bridge
   ensure piercer_webview
   ```
6. Join the game and type `/yourcommand`. Done! 🎉

## ⚙️ Configuration

Everything lives in [`config.lua`](config.lua):

| Option | Type | Default | Description |
|---|---|---|---|
| `Config.url` | `string` | — | Address of the site to open (with `https://`) |
| `Config.command` | `string` | — | Command to open it, **without the slash** (e.g. `"store"` → `/store`) |
| `Config.key` | `string` | `""` | Default key (e.g. `"F7"`). `""` = no key |
| `Config.mode` | `string` | `"auto"` | `"auto"` (iframe, and DUI if the site blocks iframes), `"iframe"` or `"dui"` |
| `Config.fixUrls` | `boolean` | `true` | Converts YouTube links to `/embed/` and adds `igu=1` to Google |
| `Config.warnBlocked` | `boolean` | `true` | Warns in the console and in the window when the site blocks iframes |
| `Config.perms` | `table` | `{}` | Who can open it (see the table below). Empty = everyone |
| `Config.title` | `string` | `""` | Title text at the top of the window |
| `Config.highlight` | `string` | `""` | Part of the title painted with the accent color |
| `Config.color` | `string` | `"#9a9a9a"` | Accent color (title and ID) |
| `Config.denied` | `string` | `"You don't have access to this."` | Message when the player lacks permission |
| `Config.showId` | `boolean` | `false` | Shows the character ID at the top with a copy button |
| `Config.idHint` | `string` | `"Use your ID:"` | Text shown next to the ID |
| `Config.sendParams` | `boolean` | `false` | Adds `?id=<id>&name=<name>` to the site URL |

### What "permission" and "ID" mean in each framework

The bridge translates to what your framework understands:

| Framework | `Config.perms` accepts | ID shown / sent |
|---|---|---|
| **vRP · vRPex · Creative** | permission or group | passport (`user_id`) |
| **QBCore · Qbox** | job, gang, group or ACE | `citizenid` |
| **ESX** | group (`admin`) or job | `identifier` |
| **Standalone** | ACE (`add_ace`) | Rockstar license |

> 💡 On standalone the ID is the license (`license:abc123…`). If your site doesn't use that, leave `Config.showId = false`.

### Example: VIP store

```lua
Config.url = "https://store.myserver.com"
Config.command = "store"
Config.key = "F7"
Config.perms = {}

Config.title = "STORE"
Config.highlight = "VIP"
Config.color = "#f5b301"

Config.showId = true
Config.idHint = "Enter your ID at checkout:"
Config.sendParams = true
```

### Example: staff-only panel

```lua
Config.url = "https://panel.myserver.com"
Config.command = "panel"
Config.perms = { "admin" }   -- admin group (ESX/QBCore) or "admin" permission (vRP)

Config.title = "PANEL"
Config.highlight = "STAFF"
Config.color = "#ef4444"
```

On **standalone**, allow it in `server.cfg` using an ACE:

```cfg
add_ace group.admin admin allow
```

## 🧩 Multiple sites on the same server

The resource is meant to be a **template**. To have more than one site:

```
resources/
├── framezero_bridge/
├── piercer_store/      ← copy with Config.command = "store"
├── piercer_wiki/       ← copy with Config.command = "wiki"
└── piercer_ranking/    ← copy with Config.command = "ranking"
```

Copy the folder, rename it, change `config.lua` and `ensure` each one.
You don't need to touch any other file: the resource name is detected automatically and each copy uses its own callback.

> ⚠️ Each copy needs a different `Config.command`.

## 🛟 Sites that block iframes (DUI mode)

Some sites refuse to be shown inside iframes (`X-Frame-Options` header or `Content-Security-Policy: frame-ancestors`):
YouTube (normal page), GitBook, Instagram, banks… In the NUI that becomes a black screen, and no `<iframe>` attribute gets around it.

With `Config.mode = "auto"` (default), `server.lua` does a GET on `Config.url` at startup and finds out whether the site blocks it.
If it does, the site opens via **DUI**: a separate browser, drawn by the game exactly where the window is, which isn't affected by that block.

| | iframe | DUI |
|---|---|---|
| Opens any site | ❌ only iframe-friendly ones | ✅ |
| Mouse and scroll | ✅ | ✅ |
| Keyboard | ✅ | ❌ FiveM limitation |
| Keeps the page on reopen | ✅ | ❌ reloads (the DUI is destroyed on close to save FPS) |

In DUI mode the window shows a notice with **open in browser** and **copy link**, for when the player needs to type.

> 💡 Before falling back to DUI, `Config.fixUrls` tries the iframe-friendly version of the link: `youtube.com/watch?v=ID`, `youtu.be/ID` and `/shorts/ID` become `youtube.com/embed/ID`, and Google's home/search page gets `?igu=1`.

## 🔗 Integrating with your site

With `Config.sendParams = true`, the site opens like this:

```
https://yoursite.com/?id=123&name=John%20Smith
```

On the site side, just read the params:

```js
const params = new URLSearchParams(location.search);
const id = params.get('id');
const name = params.get('name');
```

> 🔐 **Important:** these params come from the URL and **can be changed** by anyone who opens the link outside the game.
> Use them to *fill in fields* and improve the experience, **never** as proof of identity to hand out items, money or permissions.
> For that, validate on your backend (signed token, login, etc.).

## 🗂️ Structure

```
piercer_webview/
├── fxmanifest.lua   # resource manifest (depends on framezero_bridge)
├── config.lua       # ⭐ the only file you need to edit
├── client.lua       # command, key, NUI focus and DUI drawing
├── server.lua       # permission + ID/name + site preflight (iframe vs DUI)
└── nui/
    ├── index.html   # browser window
    ├── script.js    # interface logic
    └── style.css    # styling
```

### Flow

```
Player types /command
        │
        ▼
client.lua ──framezero.TriggerCallback──▶ server.lua
                                            ├─ framezero.GetPlayerId
                                            ├─ framezero.HasPermission (Config.perms)
                                            └─ returns { id, name, url, frameBlocked }
        │
        ▼
SendNUIMessage("open") ──▶ iframe with Config.url
        │                  └─ or, if the site blocks iframes: CreateDui + DrawSprite on #stage
        │
   ESC / ✕ ──▶ callback "close" ──▶ DestroyDui + SetNuiFocus(false)
```

## ❓ Common issues

<details>
<summary><b>"resource framezero_bridge is not started"</b></summary>

The bridge must be running before the resource. Check that:
- the folder is named exactly `framezero_bridge`;
- `ensure framezero_bridge` comes **before** `ensure piercer_webview` in `server.cfg`.
</details>

<details>
<summary><b>The window opens but the site is blank / "refused to connect"</b></summary>

The site refuses to be shown inside iframes (`X-Frame-Options` header or `Content-Security-Policy: frame-ancestors`).
This isn't a bug in the resource: the site's server decides it.

- With `Config.mode = "auto"` (default) this is already handled: the console shows
  `[piercer_webview] warning: https://site.com blocks iframe (X-Frame-Options: SAMEORIGIN)` and the site opens via
  **DUI** (see [Sites that block iframes](#-sites-that-block-iframes-dui-mode)).
- With `Config.mode = "iframe"` the site stays blank; the window shows the reason with a **copy link** button.
- If the console says `couldn't verify`, the server didn't reach the site at startup; `"auto"` mode
  tries iframe. If it stays black, use `Config.mode = "dui"`.

If the site is yours and you need the **keyboard**, allow the iframe in the headers:

```
Content-Security-Policy: frame-ancestors 'self' https://cfx-nui-piercer_webview
```

and **remove** `X-Frame-Options` (`ALLOW-FROM` no longer works in Chrome). The `cfx-nui-<folder>` host follows the
resource folder name: if you rename the folder, adjust this value.

</details>

<details>
<summary><b>In DUI mode the keyboard doesn't work</b></summary>

It's a FiveM limitation: it forwards mouse and scroll to the DUI, but not keystrokes. For pages where the player needs to
type (login, form), use the **open in browser** button in the notice, or allow the iframe on your site
(question above) so it opens in iframe mode.
</details>

<details>
<summary><b>I type the command and nothing happens</b></summary>

- Check that the bridge and piercer_webview started without errors (F8 and the server console).
- If you set `Config.perms`, make sure your character has one of them (see the per-framework permission table).
- The player needs to be loaded in the framework.
- Turn on `Config.Debug = true` in the bridge config to see which adapter handled each call.
</details>

<details>
<summary><b>I changed the key in the config and it didn't change in-game</b></summary>

FiveM saves `RegisterKeyMapping` per player the first time. After that, the key only changes in
*Settings › Key Bindings › FiveM*. That's FiveM's own behavior.
</details>

<details>
<summary><b>My framework / notification isn't detected</b></summary>

The bridge is what detects it. In the bridge's `config.lua` you can force the framework (`Config.Framework`) and the notification (`Config.Notify`),
or override any function in `custom/server.lua`. No need to touch piercer_webview.
</details>

## 💬 Support & community

Questions, suggestions, or want to show how you used it on your server? Join the Discord:

<a href="https://discord.gg/jZ3vTmdjU7"><img src="https://img.shields.io/badge/Join%20the%20Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord"></a>

Just ping **@piercer** there.

## 🤝 Contributing

Found a bug or have an idea? Contributions are welcome!
Take a look at [CONTRIBUTING.md](CONTRIBUTING.md) and open an *issue* or *pull request*.

## 📄 License

© PIERCER / FrameZero. All rights reserved.

<div align="center">

**[PIERCER13](https://github.com/PIERCER13)** · Discord **@piercer** · [discord.gg/jZ3vTmdjU7](https://discord.gg/jZ3vTmdjU7)

</div>
