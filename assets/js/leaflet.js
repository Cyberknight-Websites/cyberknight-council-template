async function loadCSS(url) {
    return new Promise((resolve, reject) => {
      if (document.querySelector(`link[href="${url}"]`)) {
        resolve();
        return;
      }
      const link = document.createElement('link');
      link.rel = 'stylesheet';
      link.href = url;
      link.onload = resolve;
      link.onerror = reject;
      document.head.appendChild(link);
    });
  }

async function loadScript(url) {
    return new Promise((resolve, reject) => {
        if (document.querySelector(`script[src="${url}"]`)) {
        resolve();
        return;
        }
        const script = document.createElement('script');
        script.src = url;
        script.onload = resolve;
        script.onerror = reject;
        document.head.appendChild(script);
    });
}

async function initEventMap() {
  const mapElement = document.getElementById('map');
  if (!mapElement) {
    setTimeout(initEventMap, 100);
    return;
  }

  try {
    await loadCSS('https://unpkg.com/leaflet@1.9.4/dist/leaflet.css');
    await loadScript('https://unpkg.com/leaflet@1.9.4/dist/leaflet.js');

    const lat = parseFloat(mapElement.dataset.lat);
    const lng = parseFloat(mapElement.dataset.lng);

    const map = L.map('map');

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

    L.marker([lat, lng]).addTo(map);
    map.setView([lat, lng], 15);
  } catch (error) {
    console.error('Failed to load map:', error);
  }
}

async function initHomepageParishMap() {
  const mapElement = document.getElementById('map');
  if (!mapElement) {
    setTimeout(initHomepageParishMap, 100);
    return;
  }

  try {
    await loadCSS('https://unpkg.com/leaflet@1.9.4/dist/leaflet.css');
    await loadScript('https://unpkg.com/leaflet@1.9.4/dist/leaflet.js');

    const map = L.map('map');

    // Add a tile layer to the map
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

    const markerCoordinates = parishData.markerCoordinates;
    const parishNames = parishData.parishNames;
    const parishAddresses = parishData.parishAddresses;

    for (let i = 0; i < markerCoordinates.length; i++) {
      const marker = L.marker(markerCoordinates[i]).addTo(map);
      const appleMapsLink = "http://maps.apple.com/?near=" + markerCoordinates[i][0] + "," + markerCoordinates[i][1] + "&q=" + encodeURIComponent(parishNames[i] + " " + parishAddresses[i]);
      marker.bindPopup(`<p><b>${parishNames[i]}</b><br>${parishAddresses[i]}</p><a href='${appleMapsLink}'>Get Directions</a>`);
    }

    // Center the map
    let lat = 0;
    let lng = 0;
    for (let i = 0; i < markerCoordinates.length; i++) {
      lat += markerCoordinates[i][0];
      lng += markerCoordinates[i][1];
    }
    lat /= markerCoordinates.length;
    lng /= markerCoordinates.length;
    map.setView([lat, lng], 13);

    // Add event listeners to 'Center on Map' links
    const links = document.querySelectorAll('.homepage-parish-location-inner-links a.center-on-map-link');
    links.forEach(function(link) {
      link.addEventListener('click', function(event) {
        event.preventDefault();
        const lat = parseFloat(link.dataset.lat);
        const lng = parseFloat(link.dataset.lng);
        map.setView([lat, lng], 13);
      });
    });
  } catch (error) {
    console.error('Failed to load map:', error);
  }
}
