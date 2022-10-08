const engine = new Engine(GODOT_CONFIG)

const canvas = document.querySelector('#canvas')
const gameContainer = document.querySelector('.game-container')
canvas.onclick = canvasFullscreen
window.onresize = resizeCanvas
resizeCanvas()

const startButton = document.querySelector('.play')
startButton.onclick = startup

let quitPresses = 0
let forgetKeyTimeout

function resizeCanvas() {
    canvas.width = gameContainer.clientWidth * window.devicePixelRatio
    canvas.height = gameContainer.clientHeight * window.devicePixelRatio
}

function canvasFullscreen() {
    gameContainer.classList.add('game-container--fullscreen')
    resizeCanvas()
}

document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') quitPresses++

    clearTimeout(forgetKeyTimeout)
    forgetKeyTimeout = setTimeout(() => {
        quitPresses = 0
    }, 400)

    if (quitPresses >= 2) {
        canvas.blur()
        canvas.width = 0
        canvas.height = 0
        gameContainer.classList.remove('game-container--fullscreen')
        resizeCanvas()
    }
});


function startup() {
    const statusOverlay = document.querySelector('.status')
    const statusProgressBar = document.querySelector('.status-progress')
    const statusProgressLoader = document.querySelector('.status-progress-loader')
    const statusErrorText = document.querySelector('.status-progress-error-text')

    statusProgressBar.classList.remove('status-progress--hidden')
    document.querySelector('.play').classList.add('play--hidden')
    document.querySelector('.cube').classList.add('cube--spin')

    let initializing = true
    let statusMode = ''

    function setStatusMode(mode) {
        if (statusMode === mode || !initializing)
            return

        switch (mode) {
            case 'error':
                statusProgressBar.classList.add('status-progress--error')
                break
            case 'hidden':
                statusOverlay.classList.add('status--hidden')
                break
            default:
                throw new Error('Invalid status mode')
        }
        statusMode = mode
    }

    function displayError(err) {
        const msg = err.message || err
        console.error(msg)

        statusErrorText.textContent = ''
        const lines = msg.split('\n')
        lines.forEach((line) => {
            statusErrorText.appendChild(document.createTextNode(line))
            statusErrorText.appendChild(document.createElement('br'))
        })

        setStatusMode('error')
        initializing = false
    }

    if (!Engine.isWebGLAvailable()) {
        displayError('WebGL is not available in this browser')
        return
    }

    engine.startGame({
        'onProgress': (current, total) => {
            statusProgressLoader.style.width = Math.ceil(current / total * 100) + '%'
        },
    }).then(() => {
        setStatusMode('hidden')
        initializing = false
    }, displayError)
}