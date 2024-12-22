window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", event => {
    // Only switch if user hasn't explicitly chosen light/dark
    if (localStorage.getItem('theme') === 'system') {
        const newColorScheme = event.matches ? "dark" : "light";
        switchToColorTheme(newColorScheme);
    }
});
isDarkMode = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;
localStorageTheme = localStorage.getItem('theme') ? localStorage.getItem('theme') : null;

if (localStorageTheme) {
    if (localStorageTheme === 'dark')
        switchToColorTheme('dark', true);
    else
        switchToColorTheme('light', true);
}
else {
    if (isDarkMode)
        switchToColorTheme('dark', true);
    else
        switchToColorTheme('light', true);
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
    else {
        document.documentElement.setAttribute('data-theme', 'dark');
        localStorage.setItem('theme', 'dark');
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
        if (this.value === 'system') {
            localStorage.removeItem('theme');
            // Rely on system color scheme
            let systemTheme = window.matchMedia("(prefers-color-scheme: dark)").matches ? 'dark' : 'light';
            switchToColorTheme(systemTheme);
        } else {
            switchToColorTheme(this.value);
        }
    });
});
