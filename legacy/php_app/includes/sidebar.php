<div id="sidebar" class="sidebar">
    <button class="close-btn" onclick="closeMenu()">✖</button>
    <a href="#home"><i class="fas fa-home"></i> Home</a>
    <a href="#features"><i class="fas fa-cogs"></i> Features</a>
    <a href="#about"><i class="fas fa-info-circle"></i> About</a>
    <a href="#contact"><i class="fas fa-envelope"></i> Contact</a>
</div>

<div id="overlay" class="overlay" onclick="closeMenu()"></div>

<script>
    function openMenu() {
        document.getElementById("sidebar").classList.add("show-sidebar");
        document.getElementById("overlay").classList.add("show-overlay");
    }

    function closeMenu() {
        document.getElementById("sidebar").classList.remove("show-sidebar");
        document.getElementById("overlay").classList.remove("show-overlay");
    }
</script>
