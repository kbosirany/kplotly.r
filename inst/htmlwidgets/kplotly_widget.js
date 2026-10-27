// Draws the plotly.js figure built by kplotly.r: `x` holds `data` (traces),
// `layout` and `config`.
HTMLWidgets.widget({
  name: "kplotly_widget",
  type: "output",

  factory: function(el, width, height) {
    return {
      renderValue: function(x) {
        Plotly.react(el, x.data, x.layout, x.config);
      },

      resize: function(width, height) {
        if (el.layout) {
          Plotly.Plots.resize(el);
        }
      }
    };
  }
});
