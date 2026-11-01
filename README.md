<div align="center">

# 🌐 piercer_webview

**Abra qualquer site dentro do GTA V, direto no seu servidor FiveM.**

Um navegador in-game leve, bonito e 100% configurável, que funciona em **qualquer framework**.
Loja, painel, formulário de whitelist, ranking, wiki, mapa… se tem link, abre no jogo.

![FiveM](https://img.shields.io/badge/FiveM-resource-F40552?style=for-the-badge)
![Frameworks](https://img.shields.io/badge/ESX%20%C2%B7%20QBCore%20%C2%B7%20Qbox%20%C2%B7%20vRP%20%C2%B7%20standalone-2b2b2b?style=for-the-badge)
![Lua](https://img.shields.io/badge/Lua-5.4-000080?style=for-the-badge&logo=lua&logoColor=white)
![License](https://img.shields.io/badge/licen%C3%A7a-MIT-22c55e?style=for-the-badge)
[![Discord](https://img.shields.io/badge/Discord-entrar-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/jZ3vTmdjU7)

</div>

---

## 🎯 Para que serve

Muitos servidores têm coisas importantes **fora do jogo**: loja de VIP, painel da staff, formulário de whitelist, regras, ranking, mapa…
Normalmente o jogador precisa minimizar o GTA, abrir o navegador, achar o link e depois voltar. Isso quebra a imersão e muita gente desiste no meio do caminho.

O **piercer_webview** resolve isso: o jogador digita um comando (ou aperta uma tecla) e o site abre **numa janela por cima do jogo**, sem sair do servidor.
Quando termina, aperta **ESC** e volta a jogar na hora.

**Exemplos de uso:**

| Site | Como fica no jogo |
|---|---|
| 🛒 Loja de VIP / coins | `/loja` abre a loja já mostrando o ID do jogador para colar no checkout |
| 📝 Whitelist / formulário | `/whitelist` abre o formulário com o ID e o nome já preenchidos via URL |
| 🛡️ Painel da staff | `/painel` só abre para quem tem permissão de admin |
| 📖 Regras / wiki | `/regras` abre as regras do servidor pra qualquer um |
| 🏆 Ranking / estatísticas | `/ranking` com uma tecla de atalho (ex.: `F7`) |
| 🗺️ Mapa, rádio, cardápio, catálogo… | Qualquer página que tenha link e permita iframe |

## 🔧 Como funciona

1. **O jogador abre**: digita o comando configurado (ex.: `/loja`) ou aperta a tecla de atalho.
2. **O servidor confere**: pela [framezero_bridge](https://github.com/PIERCER13/framezero_bridge), o `server.lua` pega o **ID do personagem** no seu framework e, se você configurou `Config.perms`, verifica se ele tem alguma das permissões. Se não tiver, aparece a notificação de acesso negado e nada abre.
3. **A janela aparece**: o `client.lua` libera o mouse (`SetNuiFocus`) e manda a interface (NUI) abrir. A NUI carrega o seu site dentro de um **iframe**, com o título, a cor e o ID que você configurou.
4. **(Opcional) O site recebe os dados**: com `Config.sendParams = true`, o link é aberto como `seusite.com/?id=123&nome=Fulano`, e o site pode usar isso para preencher campos automaticamente.
5. **O jogador fecha**: ESC ou o botão ✕ fecham a janela e devolvem o controle ao jogo. Ao reabrir, a página **continua de onde parou** (não perde login nem scroll). Para atualizar, é só clicar em ↻.

> Tudo é controlado por **um único arquivo**: o [`config.lua`](config.lua). Você não precisa saber programar para usar.

## ✨ O que ele faz

- 🖥️ **Abre um site em uma janela** dentro do jogo (iframe com NUI), com fundo escurecido e animação de entrada.
- 🧩 **Multi-framework**: ESX, QBCore, Qbox, vRP, vRPex, Creative ou standalone, sem mudar uma linha de código.
- ⌨️ **Comando e tecla configuráveis**: o jogador ainda pode trocar a tecla em *Configurações › Teclas › FiveM*.
- 🔒 **Restrição por permissão**: deixe aberto pra todos ou só pra `admin`, `police`, `vip`…
- 🪪 **Mostra o ID do personagem** no topo com botão de **copiar**, ideal pra sites que pedem o ID do jogador.
- 🔗 **Envia `id` e `nome` na URL** (`?id=123&nome=Fulano`) para o site identificar o jogador automaticamente.
- 🎨 **Título e cor de destaque** personalizáveis, pra combinar com a identidade do seu servidor.
- 🔄 Botão de **recarregar**, fechar com **ESC** e a página **não recarrega** toda vez que você reabre (mantém login, scroll, etc.).
- 📦 **Modelo reutilizável**: precisa de 3 sites? Copie a pasta 3 vezes e troque só o `config.lua`.

## 📋 Requisitos

| Requisito | Observação |
|---|---|
| Servidor **FiveM** | Qualquer artifact recente |
| **[framezero_bridge](https://github.com/PIERCER13/framezero_bridge)** | Detecta o seu framework sozinha e cuida de ID, nome, permissão e notificação |

## 🚀 Instalação

1. Instale a **framezero_bridge** em `resources/`. A pasta precisa se chamar exatamente `framezero_bridge`.
2. Baixe este repositório (**Code › Download ZIP**) ou clone já na pasta com o nome certo:
   ```bash
   git clone https://github.com/PIERCER13/piercer_browser.git piercer_webview
   ```
3. Coloque a pasta `piercer_webview` em `resources/` do seu servidor.
4. Edite o [`config.lua`](config.lua) (pelo menos `Config.url` e `Config.command`).
5. No `server.cfg`, a ordem é: **framework → bridge → webview**:
   ```cfg
   ensure vrp              # ou es_extended, qb-core, qbx_core... (pule se for standalone)
   ensure framezero_bridge
   ensure piercer_webview
   ```
6. Entre no jogo e digite `/seucomando`. Pronto! 🎉

## ⚙️ Configuração

Tudo fica no [`config.lua`](config.lua):

| Opção | Tipo | Padrão | Descrição |
|---|---|---|---|
| `Config.url` | `string` | — | Endereço do site que será aberto (com `https://`) |
| `Config.command` | `string` | — | Comando para abrir, **sem a barra** (ex.: `"loja"` → `/loja`) |
| `Config.key` | `string` | `""` | Tecla padrão (ex.: `"F7"`). `""` = sem tecla |
| `Config.warnBlocked` | `boolean` | `true` | Avisa no console e na janela quando o site bloqueia iframe |
| `Config.perms` | `table` | `{}` | Quem pode abrir (veja a tabela abaixo). Vazio = todo mundo |
| `Config.title` | `string` | `""` | Texto do título no topo da janela |
| `Config.highlight` | `string` | `""` | Parte do título pintada com a cor de destaque |
| `Config.color` | `string` | `"#9a9a9a"` | Cor de destaque (título e ID) |
| `Config.denied` | `string` | `"Você não tem acesso a isso."` | Mensagem quando o jogador não tem permissão |
| `Config.showId` | `boolean` | `false` | Mostra o ID do personagem no topo com botão de copiar |
| `Config.idHint` | `string` | `"Use seu ID:"` | Texto exibido ao lado do ID |
| `Config.sendParams` | `boolean` | `false` | Adiciona `?id=<id>&nome=<nome>` na URL do site |

### O que é "permissão" e "ID" em cada framework

A bridge traduz para o que o seu framework entende:

| Framework | `Config.perms` aceita | ID mostrado / enviado |
|---|---|---|
| **vRP · vRPex · Creative** | permissão ou grupo | passaporte (`user_id`) |
| **QBCore · Qbox** | job, gang, grupo ou ACE | `citizenid` |
| **ESX** | grupo (`admin`) ou job | `identifier` |
| **Standalone** | ACE (`add_ace`) | license da Rockstar |

> 💡 No standalone o ID é a license (`license:abc123…`). Se o seu site não usa isso, deixe `Config.showId = false`.

### Exemplo: loja VIP

```lua
Config.url = "https://loja.meuservidor.com.br"
Config.command = "loja"
Config.key = "F7"
Config.perms = {}

Config.title = "LOJA"
Config.highlight = "VIP"
Config.color = "#f5b301"

Config.showId = true
Config.idHint = "Informe seu ID no checkout:"
Config.sendParams = true
```

### Exemplo: painel só para staff

```lua
Config.url = "https://painel.meuservidor.com.br"
Config.command = "painel"
Config.perms = { "admin" }   -- grupo admin (ESX/QBCore) ou permissão "admin" (vRP)

Config.title = "PAINEL"
Config.highlight = "STAFF"
Config.color = "#ef4444"
```

No **standalone**, libere pelo `server.cfg` usando ACE:

```cfg
add_ace group.admin admin allow
```

## 🧩 Vários sites no mesmo servidor

O resource foi pensado como **modelo**. Pra ter mais de um site:

```
resources/
├── framezero_bridge/
├── piercer_loja/      ← cópia com Config.command = "loja"
├── piercer_wiki/      ← cópia com Config.command = "wiki"
└── piercer_ranking/   ← cópia com Config.command = "ranking"
```

Copie a pasta, renomeie, troque o `config.lua` e dê `ensure` em cada uma.
Não precisa mexer em nenhum outro arquivo: o nome do resource é detectado automaticamente e cada cópia usa o próprio callback.

> ⚠️ Cada cópia precisa de um `Config.command` diferente.

## 🔗 Integrando com o seu site

Com `Config.sendParams = true`, o site é aberto assim:

```
https://seusite.com/?id=123&nome=Fulano%20Silva
```

Do lado do site, basta ler os parâmetros:

```js
const params = new URLSearchParams(location.search);
const id = params.get('id');
const nome = params.get('nome');
```

> 🔐 **Importante:** esses parâmetros vêm da URL e **podem ser alterados** por qualquer pessoa que abrir o link fora do jogo.
> Use-os para *preencher campos* e melhorar a experiência, **nunca** como prova de identidade para entregar itens, dinheiro ou permissões.
> Para isso, valide no seu backend (token assinado, login, etc.).

## 🗂️ Estrutura

```
piercer_webview/
├── fxmanifest.lua   # manifesto do resource (depende da framezero_bridge)
├── config.lua       # ⭐ o único arquivo que você precisa editar
├── client.lua       # comando, tecla, foco da NUI
├── server.lua       # permissão + ID/nome + preflight do site (iframe)
└── nui/
    ├── index.html   # janela do navegador
    ├── script.js    # lógica da interface
    └── style.css    # visual
```

### Fluxo

```
Jogador digita /comando
        │
        ▼
client.lua ──framezero.TriggerCallback──▶ server.lua
                                            ├─ framezero.GetPlayerId
                                            ├─ framezero.HasPermission (Config.perms)
                                            └─ devolve id + nome
        │
        ▼
SendNUIMessage("open") ──▶ nui/ abre o iframe com Config.url
        │
   ESC / ✕ ──▶ callback "close" ──▶ SetNuiFocus(false)
```

## ❓ Problemas comuns

<details>
<summary><b>"a resource framezero_bridge não está iniciada"</b></summary>

A bridge precisa estar rodando antes do resource. Confira se:
- a pasta se chama exatamente `framezero_bridge`;
- `ensure framezero_bridge` vem **antes** de `ensure piercer_webview` no `server.cfg`.
</details>

<details>
<summary><b>A janela abre mas o site fica em branco / "recusou a conexão"</b></summary>

O site recusa ser exibido dentro de iframes (cabeçalho `X-Frame-Options` ou `Content-Security-Policy: frame-ancestors`).
Isso acontece com Google, YouTube (página normal), GitBook, Instagram, bancos, etc., e não é bug do resource:
quem decide é o servidor do site, e nenhum atributo de `<iframe>` contorna isso.

Com `Config.warnBlocked` ligado (padrão), o resource descobre isso ao iniciar: o console do servidor mostra
`[piercer_webview] aviso: https://site.com bloqueia iframe (X-Frame-Options: SAMEORIGIN)` e a janela exibe o
motivo com um botão **copiar link** — em vez de tela preta sem explicação.

Se o site for seu, libere o iframe nos cabeçalhos:

```
Content-Security-Policy: frame-ancestors 'self' https://cfx-nui-piercer_webview
```

e **remova** o `X-Frame-Options` (o `ALLOW-FROM` não funciona mais no Chrome). O host `cfx-nui-<pasta>` segue o
nome da pasta do resource: se você renomear a pasta, ajuste o valor aqui.

> Dica: para vídeos do YouTube use o link de *embed* (`https://www.youtube.com/embed/ID`).
</details>

<details>
<summary><b>Digito o comando e nada acontece</b></summary>

- Confira se a bridge e o piercer_webview iniciaram sem erro (F8 e console do servidor).
- Se você configurou `Config.perms`, verifique se o seu personagem tem uma delas (veja a tabela de permissões por framework).
- O jogador precisa estar com o personagem carregado no framework.
- Ligue `Config.Debug = true` no config da bridge para ver qual adaptador atendeu cada chamada.
</details>

<details>
<summary><b>Mudei a tecla no config e não mudou no jogo</b></summary>

O FiveM salva o `RegisterKeyMapping` por jogador na primeira vez. Depois disso, a tecla só muda em
*Configurações › Teclas › FiveM*. Isso é comportamento do próprio FiveM.
</details>

<details>
<summary><b>Meu framework / notificação não é detectado</b></summary>

Quem detecta é a bridge. No `config.lua` dela dá pra forçar o framework (`Config.Framework`) e a notificação (`Config.Notify`),
ou sobrescrever qualquer função em `custom/server.lua`. Não precisa mexer no piercer_webview.
</details>

## 💬 Suporte e comunidade

Dúvidas, sugestões ou quer mostrar como usou no seu servidor? Entra no Discord:

<a href="https://discord.gg/jZ3vTmdjU7"><img src="https://img.shields.io/badge/Entrar%20no%20Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord"></a>

Lá é só chamar o **@piercer**.

## 🤝 Contribuindo

Achou um bug ou tem uma ideia? Contribuições são bem-vindas!
Dá uma olhada no [CONTRIBUTING.md](CONTRIBUTING.md) e abra uma *issue* ou *pull request*.

Se esse resource te ajudou, deixa uma ⭐ no repositório, isso ajuda outros devs a encontrarem o projeto.

## 📄 Licença

Distribuído sob a licença **MIT**. Use, modifique e redistribua à vontade, inclusive em servidores comerciais.
Só mantenha o aviso de copyright. Veja [LICENSE](LICENSE).

<div align="center">

**[PIERCER13](https://github.com/PIERCER13)** · Discord **@piercer** · [discord.gg/jZ3vTmdjU7](https://discord.gg/jZ3vTmdjU7)

</div>
