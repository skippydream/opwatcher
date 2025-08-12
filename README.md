![GitHub Release](https://img.shields.io/github/v/release/skippydream/opwatcher)
![Github latest release](https://img.shields.io/github/last-commit/skippydream/opwatcher)
![GitHub repo size](https://img.shields.io/github/repo-size/skippydream/opwatcher)

# One Piece Watcher

**One Piece Watcher** è un'applicazione sviluppata in SwiftUI per la visione in streaming degli episodi di **One Piece** in versione **sub ita**. L'app offre un'interfaccia semplice per navigare tra gli episodi, cercare episodi specifici e visualizzare i video con un lettore integrato che supporta la modalità schermo intero e comandi personalizzati.

## Funzionalità principali

- **Navigazione tra episodi**: Puoi facilmente passare all'episodio precedente o successivo tramite icone intuitive.
- **Ultimo episodio guardato**: L'app salva automaticamente l'ultimo episodio visto, consentendo di riprendere facilmente da dove avevi interrotto.
- **Ricerca per episodio**: Puoi cercare un episodio specifico inserendo il numero dell'episodio. Se l'episodio è un filler o un mixed filler, viene visualizzato un avviso.
- **Controllo della riproduzione**: Puoi mettere in pausa, riprendere e navigare tra gli episodi direttamente dal lettore video.
- **Supporto per modalità schermo intero**: Puoi passare facilmente alla modalità schermo intero per un'esperienza di visione più immersiva.
- **Download degli episodi tramite FFmpeg**: È stata implementata una sezione che consente il download degli episodi in locale utilizzando **FFmpeg**, offrendo la possibilità di guardarli offline. 

## Come funziona

L'app si basa su un sistema di navigazione degli episodi, permettendo agli utenti di selezionare e guardare episodi tramite un lettore video integrato. Quando viene selezionato un episodio, il video viene caricato e riprodotto tramite una URL dinamica che cambia a seconda dell'episodio scelto.

### Controlli principali

- **Indietro e Avanti**: Usa i pulsanti per spostarti tra gli episodi.
- **Cerca episodio**: Inserisci il numero dell'episodio per trovarlo rapidamente.
- **Visualizzazione episodi filler**: Se un episodio è identificato come filler o mixed filler, verrà mostrato un avviso che permette all'utente di decidere se procedere comunque con la visione.
- **Download episodi**: Accedi alla sezione download per scaricare gli episodi selezionati in locale tramite FFmpeg.

<p align="center">
  <img src="https://github.com/skippydream/opwatcher/blob/main/Images/1.png?raw=true" width="350"/>
  <img src="https://github.com/skippydream/opwatcher/blob/main/Images/2.png?raw=true" width="350"/>
</p>
<p align="center">
  <img src="https://github.com/skippydream/opwatcher/blob/main/Images/3.png?raw=true" width="350"/>
  <img src="https://github.com/skippydream/opwatcher/blob/main/Images/4.png?raw=true" width="350"/>
</p>

## Requisiti

- Xcode 12.0 o versioni successive
- macOS 10.15 (Catalina) o versioni successive
- Swift 5.0 o versioni successive

## Istruzioni per l'installazione

1. Clona il repository:
   ```bash
   git clone https://github.com/skippydream/opwatcher.git
   ```

2. Apri il progetto in Xcode.

3. Compila e avvia l'app su un simulatore o dispositivo.

## Contribuisci

Se desideri contribuire a questo progetto, puoi fare un fork e inviare una pull request con le tue modifiche.

## Licenza

Questo progetto è concesso in licenza sotto la [MIT License](LICENSE).
