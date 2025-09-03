// Custom JavaScript for Cloud Builder Hello World

// Health check functionality
function performHealthCheck() {
    fetch('/Home/Health')
        .then(response => response.json())
        .then(data => {
            console.log('Health check result:', data);
            if (data.status === 'healthy') {
                showNotification('System is healthy', 'success');
            } else {
                showNotification('System health check failed', 'danger');
            }
        })
        .catch(error => {
            console.error('Health check error:', error);
            showNotification('Health check request failed', 'danger');
        });
}

// Show notification
function showNotification(message, type) {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show position-fixed`;
    alertDiv.style.top = '20px';
    alertDiv.style.right = '20px';
    alertDiv.style.zIndex = '9999';
    alertDiv.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    document.body.appendChild(alertDiv);
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
        if (alertDiv.parentNode) {
            alertDiv.parentNode.removeChild(alertDiv);
        }
    }, 5000);
}

// Auto health check every 5 minutes
setInterval(performHealthCheck, 300000);

// Initialize when page loads
document.addEventListener('DOMContentLoaded', function() {
    console.log('Cloud Builder Hello World Application Loaded');
    
    // Add click handler for health check button
    const healthBtn = document.querySelector('a[href="/Home/Health"]');
    if (healthBtn) {
        healthBtn.addEventListener('click', function(e) {
            e.preventDefault();
            performHealthCheck();
        });
    }
});