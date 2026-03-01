const urlParts = window.location.pathname.split('/');
const token = urlParts[urlParts.length - 1];

const latEl = document.getElementById('latitude');
const lngEl = document.getElementById('longitude');

const lastUpdateEl = document.getElementById('last-update');
const mapLinkEl = document.getElementById('map-link');
const locationName = document.getElementById('location-name');

async function fetchLocation() {
    try {
        const res = await fetch(`${window.location.origin}/api/public/track/${token}`);
        if (!res.ok) throw new Error('Failed to fetch location');

        const { lat, lng, minutesSinceLastUpdate } = await res.json();

        latEl.textContent = `Latitude: ${lat}`;
        lngEl.textContent = `Longitude: ${lng}`;

        const reverseGeoCoded = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}`);
        const displayName = reverseGeoCoded.ok ? (await reverseGeoCoded.json()).display_name : '';
        locationName.textContent = displayName;
        lastUpdateEl.textContent = `Last Updated: ${minutesSinceLastUpdate} minute${minutesSinceLastUpdate !== 1 ? 's' : ''} ago`;

        mapLinkEl.href = `https://www.google.com/maps?q=${lat},${lng}`;
        mapLinkEl.style.pointerEvents = 'auto';
        mapLinkEl.style.opacity = '1';

        document.querySelector('.status-text').textContent = 'Live Tracking Active';
        document.querySelector('.pulse').style.backgroundColor = '#ef4444'; 

    } catch (err) {
        console.error('Error fetching location:', err);

        latEl.textContent = 'Latitude: unavailable';
        lngEl.textContent = 'Longitude: unavailable';
        lastUpdateEl.textContent = 'Unable to fetch location. Tracking session may have ended or expired.';
        
        // Disable map link
        mapLinkEl.href = '#';
        mapLinkEl.style.pointerEvents = 'none';
        mapLinkEl.style.opacity = '0.5';

        // Show offline status
        document.querySelector('.status-text').textContent = 'Tracking unavailable';
        document.querySelector('.pulse').style.backgroundColor = '#6b7280'; 
    }
}

// Initial fetch
fetchLocation();

setInterval(fetchLocation, 5000);