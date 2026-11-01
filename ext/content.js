// Mouse buttons 3 and 4 are the back and forward side buttons.
function onButton(e) {
  if (e.button !== 3 && e.button !== 4) return;
  e.preventDefault();
  e.stopImmediatePropagation();
  if (e.type === "mouseup") e.button === 3 ? history.back() : history.forward();
}
for (const type of ["mousedown", "mouseup", "auxclick"]) window.addEventListener(type, onButton, true);
