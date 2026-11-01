// Mouse buttons 3 = back, 4 = forward
function handle(e) {
  if (e.button !== 3 && e.button !== 4) return;
  e.preventDefault();
  e.stopImmediatePropagation();
  if (e.type === "mouseup") {
    if (e.button === 3) history.back(); else history.forward();
  }
}
for (const t of ["mousedown", "mouseup", "auxclick"]) window.addEventListener(t, handle, true);
