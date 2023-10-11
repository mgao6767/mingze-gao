// This code is to make sure when clicking on an equation's link
// generated via "\eqref", we scroll to the equation with some offet.
// This is because the menu bar is fixed on top, which will overlay
// the equation.
document.addEventListener("DOMContentLoaded", function () {
  const __offset = 100;
  // Wait until MathJax has finished typesetting the page
  MathJax.startup.promise.then(() => {
    // Find all equation reference links
    const eqrefs = document.querySelectorAll('a[href^="#mjx-eqn"]');

    // Add click event listener to each
    eqrefs.forEach((eqref) => {
      eqref.addEventListener("click", function (event) {
        // Prevent default behavior
        event.preventDefault();

        // Extract target ID from href attribute
        const targetID = eqref.getAttribute("href").substring(1);

        // Find the target element
        const targetElement = document.getElementById(targetID);

        if (targetElement) {
          // Get the position of the target element
          const rect = targetElement.getBoundingClientRect();

          // Scroll the window, accounting for the offset
          window.scrollTo(rect.left, rect.top + window.scrollY - __offset);
        }
      });
    });
  });
});
