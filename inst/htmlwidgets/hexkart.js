HTMLWidgets.widget({
  name: 'hexkart',
  type: 'output',
  factory: function(el, width, height) {
    var kartRenderer = new KartRenderer(el, width, height);
      
    return {
      renderValue: function(x) {
        if (!kartRenderer.isInit()) kartRenderer.init(
          parseInt(x.width),
          parseInt(x.height),
          parseInt(x.circuit)
        );
      },
      resize: function(width, height) {
        kartRenderer.resize(width, height);
      }
    };
  }
});