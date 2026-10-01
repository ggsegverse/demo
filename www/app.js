// Embedded mode: ?embed=1 drops the app's own title bar and footer so the app
// can sit inside a page that already has them (the ggsegverse website's
// playground). Runs from <head>, before the body paints, to avoid a flash of
// the full chrome.
if (new URLSearchParams(window.location.search).has("embed")) {
  document.documentElement.classList.add("ggsegverse-embedded");
}

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
