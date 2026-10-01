// Embedded mode: ?embed=1 drops the app's own title bar and footer so the app
// can sit inside a page that already has them (the ggsegverse website's
// playground). Runs from <head>, before the body paints, to avoid a flash of
// the full chrome.
//
// ?mode=light|dark pins the colour mode instead of following the system, so an
// embedding page can match the app to its own theme. The page keeps them in
// step afterwards by posting a "ggsegverse-set-mode" message. That message is
// accepted from any origin: it only ever flips light/dark, carries no data
// back, and any value other than those two is ignored.
(function () {
  var params = new URLSearchParams(window.location.search);

  if (params.has("embed")) {
    document.documentElement.classList.add("ggsegverse-embedded");
  }

  function applyMode(mode) {
    if (mode !== "light" && mode !== "dark") return;
    document.documentElement.setAttribute("data-bs-theme", mode);
    var toggle = document.querySelector("bslib-input-dark-mode");
    if (toggle) {
      toggle.mode = mode;
      toggle.setAttribute("mode", mode);
    }
  }

  var initial = params.get("mode");
  if (initial) {
    applyMode(initial);
    // The toggle is a custom element and Shiny owns the input behind it, so
    // reapply once both exist.
    document.addEventListener("shiny:connected", function () {
      applyMode(initial);
    });
  }

  window.addEventListener("message", function (event) {
    var data = event.data;
    if (data && data.type === "ggsegverse-set-mode") applyMode(data.mode);
  });
})();

Shiny.addCustomMessageHandler("copy-code", function(msg) {
  var el = document.getElementById(msg.id);
  if (!el) return;
  navigator.clipboard.writeText(el.innerText).then(function() {
    el.classList.add("copied");
    setTimeout(function() { el.classList.remove("copied"); }, 700);
  });
});

Shiny.addCustomMessageHandler("brand-logo", function(msg) {
  document.querySelectorAll(".ggsegverse-title img").forEach(function(img) {
    img.src = msg.src;
  });
});
