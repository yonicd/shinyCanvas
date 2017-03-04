HTMLWidgets.widget({

  name: 'fluidSpline',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

//Setup
        var item='interpolate';
        var aForm=document.createElement("Form");
        var aLabel = document.createElement("Label");
            aLabel.setAttribute("for", item);
            aLabel.innerHTML = "Interpolate:";
        var aSelect=document.createElement("Select");
            aSelect.setAttribute("id", item);
        /*var aButton = document. createElement("button");    
            aButton. innerHTML = "Animate";*/
            
        el.appendChild(aForm);
        aForm.appendChild(aLabel);
        aForm.appendChild(aSelect);
        //aForm.appendChild(aButton);
        
        var margin={top:20,right:20,bottom:30,left:40};
        var width = x.width-margin.left-margin.right;
        var height = x.height-margin.top-margin.bottom;

 //var points= [[5,3], [10,10], [15,4], [2,8]];
 var data = x.data; 
 var axisName=Object.keys(data);
 var points = d3.range(0, x.n).map(function(i) {
          return [data[axisName[0]][i], data[axisName[1]][i]];
        });
 var pointsFloat = points[0];
 
 
// setup x 
  var xValue = function(d) { return d[0];}, // data -> value
      xScale = d3.scale.linear()
  							.domain([d3.min(points, xValue)-1, d3.max(points, xValue)+1])
                .range([ 0, width ]),
                
      xMap = function(d) { return xScale(xValue(d));}, // data -> display
      xAxis = d3.svg.axis().scale(xScale).orient("bottom");
  
  // setup y
  var yValue = function(d) { return d[1];}, // data -> value
      yScale = d3.scale.linear()
  						.domain([d3.min(points, yValue)-1, d3.max(points, yValue)+1])
      	      .range([ height, 0 ]), // value -> display
      yMap = function(d) { return yScale(yValue(d));}, // data -> display
      yAxis = d3.svg.axis().scale(yScale).orient("left");  
  
  var xScaleInv = d3.scale.linear()
  							.range([d3.min(points, xValue)-1, d3.max(points, xValue)+1])
                .domain([ 0, width ]),
    xMapInv = function(d) { return xScaleInv(d);},
    yScaleInv = d3.scale.linear()
  							.range([d3.min(points, yValue)-1, d3.max(points, yValue)+1])
      	      .domain([ height, 0 ]),
    yMapInv = function(d) { return yScaleInv(d);};
    
// add the tooltip area to the webpage
var tooltip = d3.select(el).append("div")
    .attr("class", "tooltip")
    .style("opacity", 0);

var dragged = null,
    selected = points[0];
  
var line = d3.svg.line()
.x(function(d) { return xMap(d); })
.y(function(d) { return yMap(d); });

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
      "step-before",
      "step-after",
      "basis",
      "basis-open",
      "basis-closed",
      "cardinal",
      "cardinal-open",
      "cardinal-closed",
      "monotone"
    ])
  .enter().append("option")
    .attr("value", function(d) { return d; })
    .text(function(d) { return d; });

    svg.node().focus();

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
      .text(axisName[0]);

  // y-axis
  svg.append("g")
      .attr("class", "y axis")
			.attr('transform', 'translate(0,0)')
      .call(yAxis)
    .append("text")
      .attr("class", "label")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text(axisName[1]);   

function redraw() {
  
	var path=svg.select("path").attr("d", line);

  var circle = svg.selectAll("circle").data(points);
  
  circle.enter().append("circle")
      .attr("cx", xMap)
      .attr("cy", yMap);
  
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

  circle.classed("selected", function(d) { return d === selected; })
      .attr("cx", xMap)
      .attr("cy", yMap);

  circle.exit().remove();

  if (d3.event) {
    d3.event.preventDefault();
    d3.event.stopPropagation();
  }

  circle.on("mousedown", function(d) { selected = dragged = d; redraw(); })
    .transition()
      .duration(750)
      .ease("elastic")
      .attr("r", 2);

  var circleBig = svg.append("ellipse")
  .attr("rx", 10)
  .attr("ry", 10)
  .attr('transform','translate('+ xMap(pointsFloat) + ',' + yMap(pointsFloat) +')');

transition();

function transition() {
  circleBig.transition()
      .duration(10000)
      .attrTween("transform", translateAlong(path.node()))
      .each("end", transition);
}

function translateAlong(path) {
  var l = path.getTotalLength();
  return function(d, i, a) {
    return function(t) {
      var p = path.getPointAtLength(t * l);
      return "translate(" + p.x + "," + p.y + ")";
    };
  };
} 

 if(typeof(Shiny) !== "undefined"){
    Shiny.onInputChange(el.id + "_update",{
      ".pointsData": JSON.stringify(points)
    });
 }

}

function change() {
  line
  .tension(0)
  .interpolate(this.value);
  svg.selectAll("ellipse").remove();
  redraw();
}

function mousedown() {
  points.push(selected = dragged = d3.mouse(svg.node()));
  var m = d3.mouse(svg.node());
  dragged[0] = xMapInv(Math.max(0, Math.min(width, m[0])));
  dragged[1] = yMapInv(Math.max(0, Math.min(height, m[1])));
  svg.selectAll("ellipse").remove();
  redraw();
}

function mousemove() {
  if (!dragged) return;
  var m = d3.mouse(svg.node());
  dragged[0] = xMapInv(Math.max(0, Math.min(width, m[0])));
  dragged[1] = yMapInv(Math.max(0, Math.min(height, m[1])));
  svg.selectAll("ellipse").remove();
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
      svg.selectAll("ellipse").remove();
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