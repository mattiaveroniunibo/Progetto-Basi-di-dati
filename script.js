// script.js COMPLETO E FUNZIONANTE

// Caricamento dinamico delle pagine
function loadPage(page) {
    console.log("Loading page:", page);

    const isLoggedIn = !!sessionStorage.getItem("userEmail");

    if (page === "profilo" && !isLoggedIn) {
        document.getElementById("content").innerHTML = `
            <div class='alert'>
                <h3>Accesso negato</h3>
                <p>Effettua il login per accedere al profilo.</p>
            </div>
        `;
        return;
    }    

    if (page === "login") {
        loadLoginPage();
    } else if (page === "profilo") {
        const isAdmin = sessionStorage.getItem("isAdmin") === "1";
        console.log("isAdmin:", isAdmin);
    
        let html = `
            <div class='profilo'>
                <h2>Il Mio Profilo</h2>
                <p>Informazioni personali e progetti supportati.</p>
        `;
    
        if (isAdmin) {
            html += `
                <hr class="my-4">
                <div class="card border-dark">
                    <div class="card-header bg-dark text-white">
                        Pannello Amministratore
                    </div>
                    <div class="card-body">
                        <form id="skillForm">
                            <div class="mb-3">
                                <label for="skillName" class="form-label">Nome competenza</label>
                                <input type="text" class="form-control" id="skillName" required>
                            </div>
                            <div class="mb-3">
                                <label for="skillLevel" class="form-label">Livello (0-5)</label>
                                <input type="number" class="form-control" id="skillLevel" min="0" max="5" required>
                            </div>
                            <button type="submit" class="btn btn-success">Aggiungi Skill</button>
                        </form>
                    </div>
                </div>
            `;

        }
    
        html += `</div>`;
        document.getElementById("content").innerHTML = html;
    
        // Collega il form se l'admin esiste davvero
        if (isAdmin) {
            const skillForm = document.getElementById("skillForm");
            if (skillForm) {
                skillForm.addEventListener("submit", async function (e) {
                    e.preventDefault();
    
                    const name = document.getElementById("skillName").value;
                    const level = document.getElementById("skillLevel").value;
                    const email = sessionStorage.getItem("userEmail");
                    
                    const formData = new FormData();
                    formData.append("competenza", name);
                    formData.append("livello", level);
                    formData.append("email", email);
    
                    const response = await fetch("aggiungi_skill.php", {
                        method: "POST",
                        body: formData
                    });
    
                    const data = await response.json();
                    alert(data.message);
                });
            }
        }
    } else if (page === "progetti") {
        loadProjects(); // 💥 chiamata alla tua funzione esistente
    } else if (page === "statistiche") {
        loadStatistics(); // 💥 chiamata alla tua funzione esistente
    } else {
        document.getElementById("content").innerHTML = `
            <h2>Benvenuto</h2>
            <p>Questa è la home.</p>
        `;
    }
}

// Caricamento login + registrazione
function loadLoginPage() {
    console.log("Login page caricata");
    let html = `
        <div class="login">
            <h2>Accedi</h2>
            <form id="loginForm">
                <label>Email:</label>
                <input type="email" id="loginEmail" required>
                <label>Password:</label>
                <input type="password" id="loginPassword" required>
                <div>
                    <label><input type="checkbox" id="isAdminCheckbox"> Sono un amministratore</label>
                </div>
                <div id="adminCodeContainer" style="display: none;">
                    <label>Codice sicurezza:</label>
                    <input type="text" id="adminCode">
                </div>
                <button type="submit">Accedi</button>
            </form>

            <hr>

            <h3>Registrati</h3>
            <form id="registerForm">
                <input type="email" id="regEmail" placeholder="Email" required>
                <input type="text" id="regNickname" placeholder="Nickname" required>
                <input type="password" id="regPassword" placeholder="Password" required>
                <input type="text" id="regNome" placeholder="Nome" required>
                <input type="text" id="regCognome" placeholder="Cognome" required>
                <input type="date" id="regAnnoNascita" required>
                <input type="text" id="regLuogoNascita" placeholder="Luogo di nascita" required>
                <button type="submit">Registrati</button>
            </form>
        </div>
    `;
    document.getElementById("content").innerHTML = html;

    document.getElementById("isAdminCheckbox").addEventListener("change", (e) => {
        document.getElementById("adminCodeContainer").style.display = e.target.checked ? "block" : "none";
    });
    document.getElementById("registerForm").addEventListener("submit", registerUser);
    document.getElementById("loginForm").addEventListener("submit", loginUser);
}

// Registrazione utente
async function registerUser(event) {
    event.preventDefault();
    let formData = new FormData();
    formData.append("email", document.getElementById("regEmail").value);
    formData.append("nickname", document.getElementById("regNickname").value);
    formData.append("password", document.getElementById("regPassword").value);
    formData.append("nome", document.getElementById("regNome").value);
    formData.append("cognome", document.getElementById("regCognome").value);
    formData.append("anno_nascita", document.getElementById("regAnnoNascita").value);
    formData.append("luogo_nascita", document.getElementById("regLuogoNascita").value);

    let response = await fetch("register.php", { method: "POST", body: formData });
    let data = await response.json();

    alert(data.message);
    if (data.success) {
        sessionStorage.setItem("userEmail", document.getElementById("regEmail").value);
        checkLoginStatus();
        loadPage("profilo");
    }
}


// Stato login
function checkLoginStatus() {
    const navLinks = document.querySelector(".nav-links");
    const isLoggedIn = !!sessionStorage.getItem("userEmail");

    if (isLoggedIn) {
        navLinks.innerHTML = `
            <li><a href="#" onclick="loadPage('home')">Home</a></li>
            <li><a href="#" onclick="loadPage('progetti')">Progetti</a></li>
            <li><a href="#" onclick="loadPage('statistiche')">Statistiche</a></li>
            <li><a href="#" onclick="loadPage('profilo')">Profilo</a></li>
            <li><a href="#" onclick="logout()">Logout</a></li>
        `;
    } else {
        navLinks.innerHTML = `
            <li><a href="#" onclick="loadPage('home')">Home</a></li>
            <li><a href="#" onclick="loadPage('progetti')">Progetti</a></li>
            <li><a href="#" onclick="loadPage('statistiche')">Statistiche</a></li>
            <li><a href="#" onclick="loadPage('login')">Accedi</a></li>
        `;
    }
}

// Login utente/admin
async function loginUser(event) {
    event.preventDefault();

    const formData = new FormData();
    formData.append("email", document.getElementById("loginEmail").value);
    formData.append("password", document.getElementById("loginPassword").value);

    const isAdminCheckbox = document.getElementById("isAdminCheckbox").checked;
    if (isAdminCheckbox) {
        formData.append("is_admin", "1");
        formData.append("security_code", document.getElementById("adminCode").value);
    }

    const response = await fetch("login.php", {
        method: "POST",
        body: formData
    });

    const data = await response.json();
    alert(data.message);

    if (data.success) {
        sessionStorage.setItem("userEmail", data.email);

        if (data.admin === "1") {
            sessionStorage.setItem("isAdmin", "1");
        } else {
            sessionStorage.removeItem("isAdmin");
        }

        checkLoginStatus(); // 🔄 aggiorna navbar
        loadPage("profilo"); // ✅ porta sempre a profilo
    }
}

// Logout
async function logout() {
    let response = await fetch("logout.php");
    let data = await response.json();

    if (data.success) {
        sessionStorage.removeItem("userEmail");
        checkLoginStatus();
        loadPage("home");
    }
}


// Funzione per caricare i progetti dal database
async function loadProjects() {
    try {
        let response = await fetch("get_projects.php");
        if (!response.ok) {
            throw new Error("Errore nel caricamento dei dati");
        }
        let projects = await response.json();
        let container = document.getElementById("content");

        let html = `<div class='progetti'><h2>Progetti Disponibili</h2><div class="project-list">`;
        projects.forEach(project => {
            let statoClass = project.Stato === "aperto" ? "stato-aperto" : "stato-chiuso";
            html += `
                <div class="project-card">
                    <h3>${project.Nome}</h3>
                    <p><strong>Creatore:</strong> ${project.Creatore}</p>
                    <p>${project.Descrizione}</p>
                    <p><strong>Budget:</strong> €${project.Budget}</p>
                    <p><strong>Finanziamenti Ricevuti:</strong> €${project.FinanziamentiRicevuti}</p>
                    <p class="status ${statoClass}"><strong>Stato:</strong> ${project.Stato}</p>
                </div>
            `;
        });
        html += `</div></div>`;
        container.innerHTML = html;
    } catch (error) {
        document.getElementById("content").innerHTML = "<h2>Errore nel caricamento dei progetti.</h2>";
    }
}

// Funzione per caricare le statistiche dal database
async function loadStatistics() {
    try {
        let response = await fetch("get_statistics.php");
        if (!response.ok) {
            throw new Error("Errore nel caricamento delle statistiche");
        }
        let stats = await response.json();
        console.log(stats); // per debug

        let container = document.getElementById("content");
        let html = `<div class='statistiche'><h2>Statistiche</h2><div class="statistiche-grid">`;

        // Classifica Creatori
        html += `<div class="stat-box"><h3>Top 3 Creatori più Affidabili</h3><ol>`;
        stats.top_creatori.forEach(creator => {
            html += `<li>${creator.Nickname}</li>`;
        });
        html += `</ol></div>`;

        // Progetti Quasi Completati
        html += `<div class="stat-box"><h3>Progetti più vicini al completamento</h3><ol>`;
        stats.top_progetti.forEach(project => {
            html += `<li>${project.Nome}</li>`;
        });
        html += `</ol></div>`;

        // Classifica Finanziatori
        html += `<div class="stat-box"><h3>Top 3 Utenti con più Finanziamenti</h3><ol>`;
        stats.top_finanziatori.forEach(user => {
            html += `<li>${user.Nickname}</li>`;
        });
        html += `</ol></div>`;

        html += `</div></div>`; // chiusura griglia e contenitore
        container.innerHTML = html;

    } catch (error) {
        console.error("Errore statistiche:", error);
        document.getElementById("content").innerHTML = "<h2>Errore nel caricamento delle statistiche.</h2>";
    }
}

document.addEventListener("DOMContentLoaded", () => {
    console.log("📦 DOM completamente caricato");
    checkLoginStatus();
    loadPage("home");
});
