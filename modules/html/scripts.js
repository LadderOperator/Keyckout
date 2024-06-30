var tabs, contents, activeIndex;
function showTab(index) {
    tabs.forEach(t => t.classList.remove('active'));
    contents.forEach(c => c.classList.remove('active'));
    tabs[index].classList.add('active');
    contents[index].classList.add('active');
};

function getActiveTabIndex() {
    tabs = document.querySelectorAll('.tab');
    contents = document.querySelectorAll('.content');
    return Array.from(tabs).findIndex(tab => tab.classList.contains('active'));
};

//Disable other keys, drag and right click
document.addEventListener("keydown", (event) => {
    if (event.code === 'ArrowLeft') {
        activeIndex = getActiveTabIndex();
        event.preventDefault();
        activeIndex = (activeIndex - 1 + tabs.length) % tabs.length;
        showTab(activeIndex);
    } else if (event.code === 'ArrowRight') {
        activeIndex = getActiveTabIndex();
        event.preventDefault();
        activeIndex = (activeIndex + 1) % tabs.length;
        showTab(activeIndex);
    } else if (event.code.startsWith("Arrow")) {
        return true
    } else if (event.code.startsWith("Page")) {
        return true
    } else if (event.code === "Home" || event.code === "End") {
        return true
    }
    event.preventDefault();
});
document.addEventListener('mousedown', (event) => {
    event.preventDefault();
});
// document.addEventListener('contextmenu', (event) => {
//     event.preventDefault();
// });
