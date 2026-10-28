// Draws the plotly.js figure built by kplotly.r: `x` holds `data` (traces),
// `layout` and `config`.
//
// plotly.js reserves no margin for a legend anchored to the container (the
// horizontal legends at the top and the bottom): with many entries it wraps
// on several rows and covers the plot and the range slider. The height of
// the legend is measured once drawn, and added to the margin on its side. At
// the bottom the margin is only the legend: the axes reserve their own room
// (tick labels, title, range slider) on top of it. At the top, the room of
// the title is kept.
function fitLegend(el, top) {
  var legend = el.layout && el.layout.legend;
  var full = el._fullLayout && el._fullLayout.legend;
  if (!legend || legend.yref !== "container" || !full || !full._height) {
    return Promise.resolve();
  }
  var side = legend.yanchor === "top" ? "t" : "b";
  // a long legend scrolls beyond `maxheight` (a fraction of the figure)
  var shown = full._height;
  if (legend.maxheight && legend.maxheight <= 1) {
    shown = Math.min(shown, legend.maxheight * el._fullLayout.height);
  }
  var wanted = (side === "t" ? top : 0) + Math.ceil(shown) + 10;
  if (Math.abs(((el.layout.margin || {})[side] || 0) - wanted) < 2) {
    return Promise.resolve();
  }
  var update = {};
  update["margin." + side] = wanted;
  return Plotly.relayout(el, update);
}

HTMLWidgets.widget({
  name: "kplotly_widget",
  type: "output",

  factory: function(el, width, height) {
    var top = 0;
    return {
      renderValue: function(x) {
        top = x.layout && x.layout.title ? 50 : 0;
        Plotly.react(el, x.data, x.layout, x.config).then(function() {
          return fitLegend(el, top);
        });
      },

      resize: function(width, height) {
        if (el.layout) {
          Plotly.Plots.resize(el).then(function() {
            return fitLegend(el, top);
          });
        }
      }
    };
  }
});
