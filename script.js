// Funzione per caricare le pagine dinamicamente
function loadPage(page) {
    if (page === "progetti") {
        loadProjects();
    } else if (page === "statistiche") {
        loadStatistics();
    } else if (page === "login") {
        loadLoginPage();
    } else {
        const pages = {
            'home': `<div class='home'><h2>Benvenuto su BOSTARTER!</h2><p>Scopri, finanzia e crea progetti innovativi.</p><a href='#' class='cta-button' onclick="loadPage('progetti')">Scopri i Progetti</a></div>`,
            'profilo': `<div class='profilo'><h2>Il Mio Profilo</h2><p>Informazioni personali e progetti supportati.</p></div>`
        };
        document.getElementById("content").innerHTML = pages[page] || "<h2>Errore: Pagina non trovata!</h2>";
    }
}

// Funzione per caricare il form di login e registrazione
function loadLoginPage() {
    let html = `
        <div class="login">
            <h2>Accedi</h2>
            <form id="loginForm">
                <label>Email:</label>
                <input type="email" id="loginEmail" required>
                <label>Password:</label>
                <input type="password" id="loginPassword" required>
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

    document.getElementById("registerForm").addEventListener("submit", registerUser);
    document.getElementById("loginForm").addEventListener("submit", loginUser);
}

// Funzione per registrare un nuovo utente
// Funzione per registrare un nuovo utente e reindirizzarlo alla home/profilo
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
        sessionStorage.setItem("userEmail", document.getElementById("regEmail").value); // Salva la sessione lato client
        checkLoginStatus(); // Aggiorna la navbar
        loadPage("profilo"); // Reindirizza al profilo
    }
}


// Controlla se l'utente è loggato
function checkLoginStatus() {
    let userEmail = sessionStorage.getItem("userEmail");
    let navLinks = document.querySelector(".nav-links");

    if (userEmail) {
        // Se l'utente è loggato, mostra "Logout"
        navLinks.innerHTML = `
            <li><a href="#" onclick="loadPage('home')">Home</a></li>
            <li><a href="#" onclick="loadPage('progetti')">Progetti</a></li>
            <li><a href="#" onclick="loadPage('statistiche')">Statistiche</a></li>
            <li><a href="#" onclick="loadPage('profilo')">Profilo</a></li>
            <li><a href="#" onclick="logout()">Logout</a></li>
        `;
    } else {
        // Se non è loggato, mostra "Accedi"
        navLinks.innerHTML = `
            <li><a href="#" onclick="loadPage('home')">Home</a></li>
            <li><a href="#" onclick="loadPage('progetti')">Progetti</a></li>
            <li><a href="#" onclick="loadPage('statistiche')">Statistiche</a></li>
            <li><a href="#" onclick="loadPage('login')">Accedi</a></li>
        `;
    }
}

// Modifica della funzione di login per salvare la sessione
async function loginUser(event) {
    event.preventDefault();
    let formData = new FormData();
    formData.append("email", document.getElementById("loginEmail").value);
    formData.append("password", document.getElementById("loginPassword").value);

    let response = await fetch("login.php", { method: "POST", body: formData });
    let data = await response.json();

    alert(data.message);
    if (data.success) {
        sessionStorage.setItem("userEmail", data.email); // Salva la sessione lato client
        checkLoginStatus(); // Aggiorna la navbar
        loadPage("profilo"); // Reindirizza al profilo
    }
}

// Funzione di logout
async function logout() {
    let response = await fetch("logout.php");
    let data = await response.json();
    
    if (data.success) {
        sessionStorage.removeItem("userEmail"); // Cancella la sessione lato client
        checkLoginStatus(); // Aggiorna la navbar
        loadPage("home"); // Torna alla home
    }
}

// Carica la pagina e controlla se l'utente è loggato
window.onload = () => {
    checkLoginStatus();
    loadPage("home");
};


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

        let container = document.getElementById("content");
        let html = `<div class='statistiche'><h2>Statistiche</h2>`;

        // Top Creatori
        html += `<h3>Top 3 Creatori più Affidabili</h3><ol>`;
        stats.top_creatori.forEach(creator => {
            html += `<li>${creator.Nickname} - Affidabilità: ${creator.Affidabilita}%</li>`;
        });
        html += `</ol>`;

        // Top Progetti
        html += `<h3>Progetti più vicini al completamento</h3><ul>`;
        stats.top_progetti.forEach(project => {
            let percentComplete = ((project.FinanziamentiRicevuti / project.Budget) * 100).toFixed(1);
            html += `<li>${project.Nome} - ${percentComplete}% finanziato</li>`;
        });
        html += `</ul>`;

        // Top Finanziatori
        html += `<h3>Top 3 Utenti con più Finanziamenti</h3><ul>`;
        stats.top_finanziatori.forEach(user => {
            html += `<li>${user.Nickname} - Totale finanziato: €${user.TotaleFinanziato}</li>`;
        });
        html += `</ul></div>`;

        container.innerHTML = html;
    } catch (error) {
        document.getElementById("content").innerHTML = "<h2>Errore nel caricamento delle statistiche.</h2>";
    }
}

// Carica la home all'avvio
window.onload = () => loadPage("home");
