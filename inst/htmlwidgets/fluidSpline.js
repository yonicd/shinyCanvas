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
        
var margin={top:20,right:20,bottom:30,left:40},width = x.width-margin.left-margin.right,
    height = x.height-margin.top-margin.bottom;
 

        var points = d3.range(1, x.n).map(function(i) {
          return [(data.x[i]-1) * width / x.n, 50 + data.y[i] * (height - 100)];
        });
        
        // setup x 
var xValue = function(d) { return d[0];}, // data -> value
    xScale = d3.scale.linear().range([0, width]), // value -> display
    xMap = function(d) { return xScale(xValue(d));}, // data -> display
    xAxis = d3.svg.axis().scale(xScale).orient("bottom");

// setup y
var yValue = function(d) { return d[1];}, // data -> value
    yScale = d3.scale.linear()
    .range([height, 0]), // value -> display
    yMap = function(d) { return yScale(yValue(d));}, // data -> display
    yAxis = d3.svg.axis().scale(yScale).orient("left");  

// add the tooltip area to the webpage
var tooltip = d3.select("body").append("div")
    .attr("class", "tooltip")
    .style("opacity", 0);

        
        var dragged = null,
            selected = points[0];
        
        var line = d3.svg.line();
        
var svg = d3.select(el).append("svg")
    .attr("width", width+margin.left+margin.right)
    .attr("height", height+margin.top+margin.bottom).append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
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
        
        //svg.node().focus();
          // x-axis
  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)
    .append("text")
      .attr("class", "label")
      .attr("x", width)
      .attr("y", -6)
      .style("text-anchor", "end")
      .text("X axis");

  // y-axis
  svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("class", "label")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Y axis");   
  
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
        circle.on("mouseover", function(d) {
          tooltip.transition()
               .duration(200)
               .style("opacity", 0.9);
          tooltip.html("(" + d3.round(xValue(d),1) + ", " + 		d3.round(yValue(d),1) + ")")
               .style("left", (d3.event.pageX) + "px")
               .style("top", (d3.event.pageY) + "px");
      })
      .on("mouseout", function(d) {
          tooltip.transition()
               .duration(500)
               .style("opacity", 0);
      });
      
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
                  ".pointsData": JSON.stringify(pointsOut)
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