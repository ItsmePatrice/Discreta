const urlParts = window.location.pathname.split('/');
const token = urlParts[urlParts.length - 1];

const coordsEl = document.getElementById('coords');
const lastUpdateEl = document.getElementById('last-update');
const mapLinkEl = document.getElementById('map-link');

async function fetchLocation() {
    try {
        const res = await fetch(`${window.location.origin}/api/public/track/${token}`);
        if (!res.ok) throw new Error('Failed to fetch location');

        const { lat, lng, minutesSinceLastUpdate } = await res.json();

        coordsEl.textContent = `Latitude: ${lat}, Longitude: ${lng}`;
        lastUpdateEl.textContent = `Last Updated: ${minutesSinceLastUpdate} minute${minutesSinceLastUpdate !== 1 ? 's' : ''} ago`;
        mapLinkEl.href = `https://www.google.com/maps?q=${lat},${lng}`;
    } catch (err) {
        console.error('Error fetching location:', err);
    }
}

// Initial fetch
fetchLocation();

setInterval(fetchLocation, 5000);