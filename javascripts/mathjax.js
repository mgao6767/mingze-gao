window.MathJax = {
  tex: {
    inlineMath: [["\\(", "\\)"]],
    displayMath: [["\\[", "\\]"]],
    processEscapes: true,
    processEnvironments: true,
    tags: "ams",
    packages: { "[+]": ["color", "tagformat"] },
    tagformat: {
      number: (n) => n.toString(),
      tag: (tag) => "(" + tag + ")",
      id: (id) => "mjx-eqn-" + id.replace(/\s/g, "_").replace(/:/g, "-"),
      url: (id, base) => base + "#" + encodeURIComponent(id),
    },
  },
  loader: { load: ["[tex]/color", "[tex]/tagformat"] },
  options: {
    ignoreHtmlClass: ".*|",
    processHtmlClass: "arithmatex",
    renderActions: {
      assistiveMml: [], // Disable assistive MathML
    },
  },
};

document$.subscribe(() => {
  MathJax.typesetPromise();
});
