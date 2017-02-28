HTMLWidgets.widget({

  name: 'fluidSpline',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {
        var data = x.data;

        var item='interpolate';
        var aForm=document.createElement("Form");
        var aLabel = document.createElement("Label");
            aLabel.setAttribute("for", item);
            aLabel.innerHTML = "Interpolate:";
        var aSelect=document.createElement("Select");
            aSelect.setAttribute("id", item);
            
        el.appendChild(aForm);
        aForm.appendChild(aLabel);
        aForm.appendChild(aSelect);
        
        var width = x.width,
            height = x.height;

        var points = d3.range(1, x.n).map(function(i) {
          return [(data.x[i]-1) * width / x.n, 50 + data.y[i] * (height - 100)];
        });
        
        var dragged = null,
            selected = points[0];
        
        var line = d3.svg.line();
        
        var svg = d3.select(el).append("svg")
            .attr("width", width)
            .attr("height", height)
            .attr("tabindex", 1);
        
        svg.append("rect")
            .attr("width", width)
            .attr("height", height)
            .on("mousedown", mousedown);
        
        svg.append("path")
            .datum(points)
            .attr("class", "line")
            .call(redraw);
        
        d3.select(window)
            .on("mousemove", mousemove)
            .on("mouseup", mouseup)
            .on("keydown", keydown);
        
        d3.select("#interpolate")
            .on("change", change)
          .selectAll("option")
            .data([
              "linear",
            	"cardinal",
            	"monotone",
              "basis",
              "step-before",
              "step-after",
              "basis-open",
              "basis-closed",
              "cardinal-open",
              "cardinal-closed"
            ])
          .enter().append("option")
            .attr("value", function(d) { return d; })
            .text(function(d) { return d; });
        
        svg.node().focus();
        
        function redraw() {
          svg.select("path").attr("d", line);
        
          var circle = svg.selectAll("circle")
              .data(points, function(d) { return d; });
        
          circle.enter().append("circle")
              .attr("r", 1e-6)
              .on("mousedown", function(d) { selected = dragged = d; redraw(); })
            .transition()
              .duration(750)
              .ease("elastic")
              .attr("r", 6.5);
        
          circle
              .classed("selected", function(d) { return d === selected; })
              .attr("cx", function(d) { return d[0]; })
              .attr("cy", function(d) { return d[1]; });
        
          circle.exit().remove();
        
          if (d3.event) {
            d3.event.preventDefault();
            d3.event.stopPropagation();
          }
          
           var pointsOut = points;

			       if(typeof(Shiny) !== "undefined"){
                Shiny.onInputChange(el.id + "_update",{
                  ".pointsData": JSON.decycle(pointsOut)
                });
			       }
        }
        
        function change() {
          line.interpolate(this.value);
          redraw();
        }
        
        function mousedown() {
          points.push(selected = dragged = d3.mouse(svg.node()));
          redraw();
        }
        
        function mousemove() {
          if (!dragged) return;
          var m = d3.mouse(svg.node());
          dragged[0] = Math.max(0, Math.min(width, m[0]));
          dragged[1] = Math.max(0, Math.min(height, m[1]));
          redraw();
        }
        
        function mouseup() {
          if (!dragged) return;
          mousemove();
          dragged = null;
        }
        
        function keydown() {
          if (!selected) return;
          switch (d3.event.keyCode) {
            case 8: // backspace
            case 46: { // delete
              var i = points.indexOf(selected);
              points.splice(i, 1);
              selected = points.length ? points[i > 0 ? i - 1 : 0] : null;
              redraw();
              break;
            }
          }
        }

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});