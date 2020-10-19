function toggle_solution() {
    var x = document.getElementById("errore");
    var y = document.getElementById("soluzione");

    if (x.style.display === "none") {
        x.style.display = "block";
        y.style.display = "none";
    }
    else {
        y.style.display = "block";
        x.style.display = "none";
    }
} 
