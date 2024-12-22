window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", event => {
    // Only switch if user hasn't explicitly chosen light/dark
    if (localStorageTheme) {
        if (localStorage.getItem('theme') === 'system') {
            switchToColorTheme('system');
        }
    }
});

isDarkMode = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;
localStorageTheme = localStorage.getItem('theme') ? localStorage.getItem('theme') : null;

if (localStorageTheme) {
    if (localStorageTheme === 'dark')
        switchToColorTheme('dark', true);
    else if (localStorageTheme === 'light')
        switchToColorTheme('light', true);
    else if (localStorageTheme === 'system') {
        switchToColorTheme('system', true);
    }
}
else {
    // if (isDarkMode)
    //     switchToColorTheme('dark', true);
    // else
    //     switchToColorTheme('light', true);
    switchToColorTheme('system', true);
}

function switchToColorTheme(themeChangeto, pageload = false) {
    if (!pageload) {
        document.documentElement.classList.add('transition');
        transition();
    }
    if (themeChangeto === 'light') {
        document.documentElement.setAttribute('data-theme', 'light');
        localStorage.setItem('theme', 'light');
    }
    else if (themeChangeto === 'dark') {
        document.documentElement.setAttribute('data-theme', 'dark');
        localStorage.setItem('theme', 'dark');
    }
    else if (themeChangeto === 'system') {
        var isDarkMode = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;
        if (isDarkMode)
            document.documentElement.setAttribute('data-theme', 'dark');
        else
            document.documentElement.setAttribute('data-theme', 'light');
        // document.documentElement.setAttribute('data-theme', 'system');
        localStorage.setItem('theme', 'system');
    }
}

function transition() {
    document.documentElement.classList.add('transition');
    window.setTimeout(() => {
        document.documentElement.classList.remove('transition');
    }, 1000);
}

document.addEventListener('DOMContentLoaded', function() {
    let themeDropdown = document.querySelector('#theme-dropdown');
    themeDropdown.value = localStorageTheme === 'dark' ? 'dark'
        : localStorageTheme === 'light' ? 'light' : 'system';

    themeDropdown.addEventListener('change', function() {
        switchToColorTheme(this.value);
    });
});
