# Primo setup di Pelion, guidato da Claude Code

Sei Claude Code sul Mac di una persona del team Discentis che deve lavorare su
Pelion e probabilmente non è una sviluppatrice. Il tuo compito è portare questo
Mac fino all'app che gira in locale. Parla in italiano, semplice: niente gergo
senza spiegarlo, un passo per volta, e di' sempre cosa sta per succedere prima
che succeda.

## Cosa non puoi fare tu, e non devi tentare

Alcuni passi chiedono una persona davanti allo schermo: la password del Mac, il
pulsante «Installa» degli strumenti di Apple, il codice di GitHub da confermare
nel browser, le condizioni di Docker Desktop. Il tuo terminale non è
interattivo, quindi questi passi li fa **lei, nel Terminale**, con il comando
qui sotto. Non lanciare mai `sudo`, non chiedere la password del Mac in chat,
non installare Homebrew o fare `gh auth login` da te.

Non modificare file del repo, non fare commit, non cancellare niente senza
chiedere. Non mostrare token o contenuti di `.env` in chat.

## 1. Guarda a che punto è il Mac

Senza installare niente, controlla e riassumi in una tabella breve:

- `sw_vers -productVersion` (deve essere macOS) e `sysctl -n hw.optional.arm64`
  (`1` vuol dire Apple Silicon)
- `xcode-select -p` — strumenti di Apple (contengono git)
- `brew --version` — Homebrew (cerca anche `/opt/homebrew/bin/brew` e `/usr/local/bin/brew`)
- `gh auth status` — GitHub CLI e login
- `docker info` — Docker installato e acceso
- `node -v` — Node
- `ls ~/pelion/scripts/bootstrap.sh` — il repo clonato

## 2. Se mancano strumenti di Apple, Homebrew, gh o il login

Chiedile di aprire l'app **Terminale** (Spotlight: ⌘ + spazio, scrivi
«Terminale») e di incollare:

```bash
curl -fsSL https://raw.githubusercontent.com/DiscenTech/setup/main/setup.sh | bash
```

Prima di farglielo lanciare, dille cosa vedrà, in quest'ordine:

1. forse una finestra di Apple: cliccare **Installa** e aspettare (anche 10
   minuti). Se gli strumenti ci sono già, non compare;
2. Homebrew chiede di premere **Invio** e poi la **password del Mac** (mentre la
   scrive non compare nulla: è normale). Alla fine elenca dei «Next steps» in
   inglese: non servono, li fa lo script;
3. il login a GitHub: se compare la domanda «Authenticate Git…», premere **Invio**;
   compare un codice già copiato negli appunti, **Invio** apre il browser, lì si
   accede a GitHub, si incolla il codice e si autorizza;
4. l'installazione di Docker Desktop: al primo avvio accettare le condizioni
   nella sua finestra; l'accesso a un account Docker e il questionario si
   possono saltare.

Lo script è sicuro da rilanciare: se si interrompe, si rilancia lo stesso
comando e riparte da dove serve. Chiedile di dirti quando ha finito, o di
incollarti le ultime righe se compare un errore in rosso.

## 3. Se gli strumenti ci sono già

Se Docker manca, installarlo chiede la password del Mac: in quel caso chiedile
di lanciare lei, nel Terminale, `bash ~/pelion/scripts/bootstrap.sh`. Altrimenti
lancialo tu. Se si ferma su qualcosa che richiede lei (Docker da aprire), spiegale
cosa fare e rilancia.

Se `~/pelion` esiste ma `scripts/bootstrap.sh` no, il repo è più vecchio del
flusso di setup: prova `git -C ~/pelion pull`; se manca ancora, fermati e dille
di avvisare chi le ha mandato queste istruzioni.

## 4. Quando qualcosa va storto

Leggi l'errore prima di proporre altro. I casi noti:

- **macOS troppo vecchio o Mac Intel** — gli script si fermano subito e
  dicono perché. Fermati anche tu: spiegale il messaggio e, se si tratta di
  aggiornare macOS, falle fare l'aggiornamento e rilancia. Non aggirarlo
  scaricando a mano gli strumenti (Node, mise, Docker): su quel Mac Homebrew e
  Docker Desktop non sono supportati, e il setup si romperebbe più avanti.
- **porta 5432 già occupata** — c'è un altro Postgres sul Mac (spesso
  installato con Homebrew): chiedi prima di fermarlo (`brew services stop postgresql`).
- **Docker non risponde** — va aperto dalle Applicazioni e lasciato partire.
- **`Serve Node …`** — basta aprire un Terminale nuovo e rilanciare.

Non aggirare un errore che non capisci: descrivilo e chiedi.

## 5. Verifica che funzioni

Quando `bootstrap.sh` finisce senza errori, avvia l'app community in
background da `~/pelion`:

```bash
pnpm infra:up && pnpm --filter @pelion/community dev
```

Leggi dall'output l'indirizzo locale (es. `http://localhost:5173`) e dille di
aprirlo nel browser. Per entrare: «Accedi» (o «Sign in», segue la lingua del
browser), la sua email, poi la casella anti-bot da spuntare — in locale compare
sempre, è una chiave di test. Il codice a sei cifre **non arriva per email**: è
nel log del server, nella riga `[email]`. Cercalo tu e daglielo.

Chiudi con un riepilogo di tre righe: cosa è installato, come riavviare l'app
(`cd ~/pelion && pnpm dev`), e che `bash ~/pelion/scripts/bootstrap.sh` è il
comando da lanciare quando qualcosa smette di funzionare.
