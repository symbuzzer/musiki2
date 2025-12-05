// MediaSession API handler for MPRIS integration
if ('mediaSession' in navigator) {
    navigator.mediaSession.setActionHandler('play', function() {
        var playBtn = document.querySelector('.play-pause-button, #play-pause-button, [aria-label*="Play"]');
        if (playBtn) playBtn.click();
    });
    navigator.mediaSession.setActionHandler('pause', function() {
        var pauseBtn = document.querySelector('.play-pause-button, #play-pause-button, [aria-label*="Pause"]');
        if (pauseBtn) pauseBtn.click();
    });
    navigator.mediaSession.setActionHandler('nexttrack', function() {
        var nextBtn = document.querySelector('.next-button, [aria-label*="Next"]');
        if (nextBtn) nextBtn.click();
    });
    navigator.mediaSession.setActionHandler('previoustrack', function() {
        var prevBtn = document.querySelector('.previous-button, [aria-label*="Previous"]');
        if (prevBtn) prevBtn.click();
    });
}
