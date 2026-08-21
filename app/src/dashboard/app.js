// AegisMind SRE Live Operations Dashboard Script

const API_BASE = window.location.origin;

let incidentsData = [];
let selectedIncidentId = null;

document.addEventListener("DOMContentLoaded", () => {
    fetchLiveData();
    setInterval(fetchLiveData, 3000); // Polling every 3s
});

async function fetchLiveData() {
    try {
        const [metricsRes, incidentsRes] = await Promise.all([
            fetch(`${API_BASE}/api/v1/metrics/summary`),
            fetch(`${API_BASE}/api/v1/incidents`)
        ]);

        if (metricsRes.ok) {
            const metrics = await metricsRes.json();
            updateMetrics(metrics);
        }

        if (incidentsRes.ok) {
            incidentsData = await incidentsRes.json();
            renderIncidentsList(incidentsData);
            if (selectedIncidentId) {
                renderRCADetails(selectedIncidentId);
            }
        }
    } catch (err) {
        console.warn("Failed to fetch live telemetry:", err);
    }
}

function updateMetrics(m) {
    document.getElementById("val-health").textContent = `${m.system_health_pct}%`;
    document.getElementById("val-remediated").textContent = m.auto_remediated;
    document.getElementById("val-mttr").textContent = `${m.mttr_seconds}s`;
    document.getElementById("val-active-alerts").textContent = m.active_alerts;
    
    const badge = document.getElementById("badge-active-alerts");
    if (m.active_alerts > 0) {
        badge.className = "metric-badge badge-warning";
        badge.textContent = `${m.active_alerts} Alerting`;
    } else {
        badge.className = "metric-badge badge-success";
        badge.textContent = "0 Active";
    }
}

function renderIncidentsList(incidents) {
    const container = document.getElementById("incident-list-container");
    if (!incidents || incidents.length === 0) {
        container.innerHTML = `
            <div class="empty-state">
                <div class="empty-icon">🌱</div>
                <p>No active incidents. Cluster operational and healthy.</p>
            </div>
        `;
        return;
    }

    container.innerHTML = incidents.map(inc => {
        const isSelected = inc.incident_id === selectedIncidentId ? "selected" : "";
        const statusClass = `status-${(inc.status || "proposed").toLowerCase()}`;

        return `
            <div class="incident-card ${isSelected}" onclick="selectIncident('${inc.incident_id}')">
                <div class="inc-card-top">
                    <span class="inc-id">${inc.incident_id}</span>
                    <span class="inc-status ${statusClass}">${inc.status}</span>
                </div>
                <div class="inc-alert-name">${inc.alertname}</div>
                <div class="inc-details">
                    <span>Target: <strong>${inc.target_resource}</strong></span>
                    <span>Ns: <strong>${inc.namespace}</strong></span>
                </div>
            </div>
        `;
    }).join("");
}

function selectIncident(incId) {
    selectedIncidentId = incId;
    renderIncidentsList(incidentsData);
    renderRCADetails(incId);
}

function renderRCADetails(incId) {
    const container = document.getElementById("rca-detail-container");
    const confTag = document.getElementById("rca-confidence-tag");
    
    const inc = incidentsData.find(i => i.incident_id === incId);
    if (!inc) return;

    confTag.textContent = `AI Confidence: ${(inc.confidence_score * 100).toFixed(0)}%`;

    const actionJson = JSON.stringify(inc.action_details || {}, null, 2);
    const remediationRes = inc.remediation_result ? JSON.stringify(inc.remediation_result, null, 2) : "Execution in progress...";

    container.innerHTML = `
        <div class="rca-block">
            <h4>Alert Trigger Summary</h4>
            <p class="rca-text"><strong>${inc.alertname}</strong> triggered on workload <code>${inc.target_resource}</code> in namespace <code>${inc.namespace}</code> at ${inc.timestamp}.</p>
        </div>

        <div class="rca-block">
            <h4>🤖 AI Root Cause Analysis</h4>
            <p class="rca-text">${inc.root_cause_analysis}</p>
        </div>

        <div class="rca-block action-card">
            <h4>⚡ Recommended Self-Healing Action</h4>
            <p class="rca-text">Action: <strong>${inc.recommended_action}</strong></p>
            <div class="code-box">${actionJson}</div>
        </div>

        <div class="rca-block">
            <h4>🛠️ K8s Control Plane Execution Status</h4>
            <div class="code-box">${remediationRes}</div>
        </div>
    `;
}

function triggerChaosModal() {
    document.getElementById("chaos-modal").classList.add("active");
}

function closeChaosModal() {
    document.getElementById("chaos-modal").classList.remove("active");
}

async function submitChaosScenario() {
    const selected = document.querySelector('input[name="scenario"]:checked').value;
    closeChaosModal();

    try {
        const resp = await fetch(`${API_BASE}/api/v1/chaos/trigger`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                scenario: selected,
                namespace: "production",
                target_deployment: "payment-gateway-service"
            })
        });

        if (resp.ok) {
            const data = await resp.json();
            selectedIncidentId = data.incident_id;
            fetchLiveData();
        }
    } catch (err) {
        alert("Failed to send chaos trigger: " + err);
    }
}
