Shiny.addCustomMessageHandler("copy-code", function(msg) {
  var el = document.getElementById(msg.id);
  if (!el) return;
  navigator.clipboard.writeText(el.innerText).then(function() {
    el.classList.add("copied");
    setTimeout(function() { el.classList.remove("copied"); }, 700);
  });
});
