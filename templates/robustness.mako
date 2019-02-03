<%!
  import os
  import glob
  import re
  from routes import url_for
  
  prefix = url_for("/")

%>
<%
  #app_root = "config/plugins/visualizations/"+visualization_name+"/"
  
  names = list(hda.datatype.dataprovider(hda, 'line', limit=1))[0].split("\t")
  
  
  data = list(hda.datatype.dataprovider(hda, 'dataset-dict'))
  #for line in data: print line
    
  uniqs  = {val : sorted(set([line[val] for line in data if line[val] is not None])) for val in names}
  #print uniqs
                 
  bounds = {val : [min(uniqs[val]),max(uniqs[val])] for val in names}

  for k in bounds:
    if(k != 'Robustness'):
      mn = bounds[k][0]
      mx = bounds[k][1]
      
      rg = mx - mn
      if mn == mx:
        if mn == 0:
          bounds[k][0] = -0.01
          bounds[k][1] =  0.01
        else:
          bounds[k][0] = mn - mn*0.01
          bounds[k][1] = mx + mx*0.01
      else:
        bounds[k][0] = mn - rg*0.01
        bounds[k][1] = mx + rg*0.01

  names = [i for i in names if i != 'Robustness']
  #print names  

%>
<html lan"en">
  
  <head>
    <title>Robustness plot</title>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <script src="https://d3js.org/d3.v4.min.js"></script>
    <script src="https://d3js.org/d3-color.v1.min.js"></script>
    <script src="https://d3js.org/d3-interpolate.v1.min.js"></script>
    <script src="https://d3js.org/d3-scale-chromatic.v1.min.js"></script>
    <script type="text/javascript" src="static/js/vendor/jquery-1.12.3.min.js"></script>
    <script type="text/javascript" src="static/js/ion-rangeSlider/ion.rangeSlider.min.js"></script>
    <script type="text/javascript" src="static/js/d3-format/d3-format.min.js"></script>

        
    <script type="text/javascript" charset="utf-8">
    
      // creates one structure containing data for JS code
      window.names = ${names};
      console.log(window.names);
      window.data  = [
      % for line in data[1:]:
        {
        % for k,v in line.items():
          ${k|n}:${v},
        % endfor
        },
      % endfor
      ];
      console.log(window.data);
      window.bounds = ${bounds};
      console.log(window.bounds);
      window.uniqs = ${uniqs};
      console.log(window.uniqs);
      
      // SPECIAL DEFINITIONS
      Set.prototype.difference = function(setB) {
          var difference = new Set(this);
          for (var elem of setB) {
              difference.delete(elem);
          }
          return difference;
      };
      d3.selection.prototype.moveUp = function() {
          return this.each(function() {
              this.parentNode.appendChild(this);
          });
      };
      d3.selection.prototype.first = function() {
        return d3.select(this[0][0]);
      };
      d3.selection.prototype.last = function() {
        var last = this.size() - 1;
        return d3.select(this[0][last]);
      };
    </script>
    
    <link rel="stylesheet" type="text/css" href="static/css/bootstrap-reboot.css">
    <link rel="stylesheet" type="text/css" href="static/css/ion.rangeSlider.css">
    <link rel="stylesheet" type="text/css" href="static/css/ion.rangeSlider.skinShiny.css">
    <link rel="stylesheet" type="text/css" href="static/css/simplex2.css">
    <link rel="stylesheet" type="text/css" href="static/css/style.css">
    <style>
      body {
        background-color: white;
        margin-top: 10px;
        font-family: sans-serif;
        //font-size: 18px;
      }
      .axis {
        font-size: 15px;
      }
      .label {
        font-size: 15px;
      }
    </style>
  </head>
    

  <body>
    <div class="my-row">
        <div class="row row-header">
            <div class="col-sm-2 lab">Horizontal axis</div>
            <div class="col-sm-2">
                <select name="xAxis" id="x_axis" class="form-control" required="">
                          % for val in names:
                            % if val == names[0]:
                              <option value="${val}" selected>${val}</option>
                            % else:
                              <option value="${val}">${val}</option>
                            % endif
                          % endfor
                </select>
            </div>
            <div class="col-sm-2 lab">Vertical axis</div>
            <div class="col-sm-2">
                <select name="yAxis" id="y_axis" class="form-control" required="">
                          % for val in names:
                            % if len(names) > 1 and val == names[1]:
                              <option value="${val}" selected>${val}</option>
                            % else:
                              <option value="${val}">${val}</option>
                            % endif
                          % endfor
                </select>
            </div>
        </div>
        <hr>
        <div class="row nohide">
            <div class="col-sm-1">
                <p align="right">Info panel:</p>
            </div>
            <div class="col-sm-11">
                <pre id="infoPanel"></pre>
            </div>
        </div>
        <div class="row nohide">
            <div class="col-sm-2">
                % if len(names) > 2:
                  % for val in names:
                    <% 
                    min_val  = 0
                    max_val  = len(uniqs[val])-1
                    real_val = uniqs[val][min_val]
                    step_val = 1
                    %>
                    % if val == names[0] or val == names[1]:
                      <div class="form-group" id="slider_${val}_wrapper" hidden>
                    % else:
                      <div class="form-group" id="slider_${val}_wrapper">
                    % endif
                                    <label class="control-label" for="slider_${val}" id="text_${val}">Value of ${val}: ${real_val}</label>
                                    <!--input class="js-range-slider" id="slider_${val}" 
                                      data-min=${min_val} data-max=${max_val} data-from=${(max_val-min_val)*0.5+min_val} data-step=${step_val} 
                                      min=${min_val} max=${max_val} value=${(max_val-min_val)*0.5+min_val} step=${step_val} data-grid="true" data-grid-num="10" 
                                      data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-data-type="number" -->
                                    <input type="range" list="tickmarks_${val}" id="slider_${val}" min=${min_val} max=${max_val} value=${min_val} step=${step_val} >
                                    <!-- maybe for the future because currently not supported everywhere -->
                                    <!--datalist id="tickmarks_${val}">
                                      % for k,v in enumerate(uniqs[val]):
                                        % if k == 0 or k == len(uniqs[val])-1:
                              <option value="${v}" label="${v}">
                            % else:
                              <option value="${v}">
                            % endif
                          % endfor
                        </datalist-->
                                </div>
                  % endfor
                % endif
            </div>
            <div class="col-sm-10 visual" id="plot_main" style="max-width:750px" width="100%"></div>
        </div>
        <div class="row row-header">
            <div class="col-sm-2 lab">Points radius</div>
            <div class="col-sm-1">
                <input class="js-range-slider" id="slider_PS_radius" data-min=1 data-max=10 data-from=4 data-step=1 min=1 max=10 value=4 step=1 
                                          data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," 
                                          data-prettify-enabled="true" data-data-type="number" width="100%" >
            </div>
            <div class="col-sm-2 lab">Feasibility scale</div>
            <div class="col-sm-2" id="color_scale" style="padding: 0% 0% 0% 0%">
                % if bounds['Robustness'][0] > 0:
                  <img src="static/YlGn.png" alt="YlGn" style="padding: 0% 10% 0% 10%"  width="100%" height="20">
                % elif bounds['Robustness'][1] < 0:
                  <img src="static/YlOrRd.png" alt="YlOrRd" style="padding: 0% 10% 0% 10%"  width="100%" height="20">
                % else:
                  <img src="static/RdYlGn.png" alt="RdYlGn" style="padding: 0% 10% 0% 10%"  width="100%" height="20">
                % endif
                <svg id="color_axis" width="100%" height="20">
                </svg>
            </div>
            
            <div class="col-sm-2 lab">Normalise</div>
            <div class="col-sm-2">
                <input type="checkbox" value="mode" class="cb" id="checkbox_normalisation" unchecked>
            </div>
            
        </div>
    </div>
    <script type="text/javascript" charset="utf-8">
    
var width = d3.select("#plot_main").property("offsetWidth"),
    height = d3.select("#plot_main").property("offsetWidth"),
    xDim = document.getElementById("x_axis").value,
    yDim = document.getElementById("y_axis").value,
    xDim_id = window.names.findIndex(x => x == xDim),
    yDim_id = window.names.findIndex(x => x == yDim),
    radius = Number(d3.select("#slider_PS_radius").property("value")),
    robustness_max = d3.max(window.bounds['Robustness'],parseFloat),
    robustness_min = d3.min(window.bounds['Robustness'],parseFloat),
    common_max = Math.max(Math.abs(robustness_max), Math.abs(robustness_min)),
    min_label_scale = robustness_min,
    max_label_scale = robustness_max


// ------------------------- new -------------------

d3.select('#checkbox_normalisation').on("change", function() {
    if(d3.select("#checkbox_normalisation").property("checked")) {
      if ((robustness_max > 0) && (robustness_min < 0)){
        max_label_scale = common_max
        min_label_scale = -common_max
      } else if (robustness_max < 0){
        max_label_scale = 0
        min_label_scale = robustness_min
      } else {
        max_label_scale = robustness_max
        min_label_scale = 0
      }
      
      calculate_gradient_middle(max_label_scale, min_label_scale);

    } else {
      max_label_scale = robustness_max
      min_label_scale = robustness_min
      
      if ((robustness_max > 0) && (robustness_min < 0)){
        gradient_middle = 0
      } else {
        calculate_gradient_middle(max_label_scale, min_label_scale);
      }
    }
    
    negative_color_scale = d3.scaleLinear()
      .domain([min_label_scale,gradient_middle])
      .range([0,0.5])
    positive_color_scale = d3.scaleLinear()
      .domain([gradient_middle,max_label_scale])
      .range([0.5,1])
      
    draw();
    draw_color_gradient_axis();
})

function calculate_gradient_middle(max_value, min_value) {
  gradient_middle = (min_value + max_value)*0.5;
}


// ------------------------ end new ---------------

// event listener for change of selectected dimension for X axis
d3.select("#x_axis").on("change", function() {
  var other = d3.select("#y_axis").property("value");
  if(this.value == other) {
    d3.select("#y_axis").property('value',xDim);
    yDim = xDim;
  } else {
    d3.select("#slider_"+xDim+"_wrapper").attr("hidden",null);
  }
  xDim = this.value;
  d3.select("#slider_"+this.value+"_wrapper").attr("hidden","hidden");

  update_axes()
  draw();
});

// event listener for change of selected dimension for Y axis
d3.select("#y_axis").on("change", function() {
  var other = d3.select("#x_axis").property("value");
  if(this.value == other) {
    d3.select("#x_axis").property('value',yDim);
    xDim = yDim;
  } else {
    d3.select("#slider_"+yDim+"_wrapper").attr("hidden",null);
  }
  yDim = this.value;
  d3.select("#slider_"+this.value+"_wrapper").attr("hidden","hidden");
  
  update_axes()
  draw();
});

// event listener for width change of plots (they should be of same size)
d3.select(window).on("resize", function() {
  draw_color_gradient_axis()
});


// iteratively adds event listener for variable sliders (according to index)
% if len(names) > 2:
  % for val in names:
      (function(i) {
          d3.select("#slider_"+i).on("input", function() {
              // update of value above the particular slider
              d3.select("#text_"+i).text("Value of "+i+": "+window.uniqs[i][Number(d3.select(this).property("value"))])
              draw();
          })
      })('${val}');
  % endfor
% endif

d3.select('#slider_PS_radius').on("change", function() {
  radius = d3.select("#slider_PS_radius").property("value")
  draw()
});

//###################################################  

var margin = { top: 20, right: 20, bottom: 70, left: 70 },
    bgColor = d3.select("body").style("background-color"),
    noColor = "transparent",
    gradient_middle = d3.min(window.bounds['Robustness'],parseFloat) == d3.max(window.bounds['Robustness'],parseFloat) ?
      d3.min(window.bounds['Robustness'],parseFloat) :
      (d3.min(window.bounds['Robustness'],parseFloat) < 0 ? 
        (d3.max(window.bounds['Robustness'],parseFloat) < 0 ? 
          (d3.min(window.bounds['Robustness'],parseFloat)+d3.max(window.bounds['Robustness'],parseFloat))*0.5 : 0) : 
        (d3.min(window.bounds['Robustness'],parseFloat)+d3.max(window.bounds['Robustness'],parseFloat))*0.5 )
    normalStrokeWidth = 1,
    hoverStrokeWidth = 4,
    transWidth = 2,
    selfloopWidth = 4;

function draw_color_gradient_axis() {
  // following is responsible for correct axis of color gradient below the gradient picture
  neg_color_xScale = d3.scaleLinear()
      .domain([min_label_scale, gradient_middle])
      .range([0.1*d3.select("#color_scale").property("offsetWidth"), 
              0.5*d3.select("#color_scale").property("offsetWidth")]);
  pos_color_xScale = d3.scaleLinear()
      .domain([gradient_middle, max_label_scale])
      .range([0.5*d3.select("#color_scale").property("offsetWidth"), 
              0.9*d3.select("#color_scale").property("offsetWidth")]);
             
  neg_color_xAxis = d3.axisBottom(neg_color_xScale)
      .tickFormat(d => d == 0 ? "0" : (Math.abs(d) < 0.01 || Math.abs(d) >= 1000 ? d3.format(".2~e")(d) : d3.format(".3~r")(d)))
      .tickValues([
          min_label_scale
          ]);
  pos_color_xAxis = d3.axisBottom(pos_color_xScale)
      .tickFormat(d => d == 0 ? "0" : (Math.abs(d) < 0.01 || Math.abs(d) >= 1000 ? d3.format(".2~e")(d) : d3.format(".3~r")(d)))
      .tickValues([
          gradient_middle,
          max_label_scale]);
          
  d3.selectAll(".colorAxis").remove();

  d3.select("#color_axis")
    .append("g")
      .attr("id", "ncXAxis")
      .attr("class", "colorAxis")
      .call(neg_color_xAxis);
  d3.select("#color_axis")
    .append("g")
      .attr("id", "pcXAxis")
      .attr("class", "colorAxis")
      .call(pos_color_xAxis);
}

function initiate_plot() {
  xScale = d3.scaleLinear()
    .domain([d3.min(window.bounds[xDim],parseFloat),
             d3.max(window.bounds[xDim],parseFloat)])
    .range([margin.left, width - margin.right]);
  
  yScale = d3.scaleLinear()
    .domain([d3.min(window.bounds[yDim],parseFloat),
             d3.max(window.bounds[yDim],parseFloat)])
    .range([height - margin.bottom, margin.top]);

  // following is responsible for correct colouring of points in the range of values in the result
  negative_color_scale = d3.scaleLinear()
    .domain([d3.min(window.bounds['Robustness'],parseFloat),gradient_middle])
    .range([0,0.5])
  positive_color_scale = d3.scaleLinear()
    .domain([gradient_middle,d3.max(window.bounds['Robustness'],parseFloat)])
    .range([0.5,1])
  
  draw_color_gradient_axis()
  
  // here stars the SVG object for the plot
  svg = d3.select("#plot_main").append("svg")
      .attr("width", width)
      .attr("height", height);
  
  container = svg.append("g")
      .attr("id","cont")
      .attr("pointer-events", "all");
      
  // important box to cover svg content outside the axis-bounded window while zooming or moving 
  svg.append("rect")
      .attr("x", 0)
      .attr("y", height-margin.bottom)
      .attr("width", width)
      .attr("height", margin.bottom)
      .attr("fill", bgColor)
  svg.append("rect")
      .attr("x", 0)
      .attr("y", 0)
      .attr("width", margin.left)
      .attr("height", height)
      .attr("fill", bgColor)
  svg.append("rect")
      .attr("x", 0)
      .attr("y", 0)
      .attr("width", width)
      .attr("height", margin.top)
      .attr("fill", bgColor)
  svg.append("rect")
      .attr("x", width-margin.right)
      .attr("y", 0)
      .attr("width", margin.right)
      .attr("height", height)
      .attr("fill", bgColor)
  
  xLabel = svg.append("text")
      .attr("id", "xlabel")
      .attr("class", "label")
      .attr("x", width*0.5)
      .attr("y", height-margin.bottom*0.2)
      .attr("stroke", "black")
      .text(function() { return xDim; });
  yLabel = svg.append("text")
      .attr("id", "ylabel")
      .attr("class", "label")
      .attr("transform", "rotate(-90)")
      .attr("x", -width*0.5)
      .attr("y", margin.left*0.2)
      .attr("stroke", "black")
      .text(function() { return yDim; });
  
  bottomPanel = svg.append("g")
      .attr("id", "bPanel")
      .attr("class", "panel")
      .style("background-color","red")
      .attr("transform", "translate("+0+","+(height-margin.bottom)+")");
      
  xAxis = d3.axisBottom(xScale)
      .tickFormat(d => d == 0 ? "0" : (Math.abs(d) < 0.01 || Math.abs(d) >= 1000 ? d3.format(".2~e")(d) : d3.format(".3~r")(d)))
  gX = bottomPanel.append("g")
      .attr("id", "xAxis")
      .attr("class", "axis")
      .call(xAxis); // Create an axis component with d3.axisBottom
  //gBX = bottomPanel.append("g")
  //    .attr("id", "xBrush")
  //    .attr("class", "brush")
  //    .call(brushX);
      
  leftPanel = svg.append("g")
      .attr("id", "lPanel")
      .attr("class", "panel")
      .attr("transform", "translate("+margin.left+","+0+")");
  
  yAxis = d3.axisLeft(yScale)
      .tickFormat(d => d == 0 ? "0" : (Math.abs(d) < 0.01 || Math.abs(d) >= 1000 ? d3.format(".2~e")(d) : d3.format(".3~r")(d)))
  gY = leftPanel.append("g")
      .attr("id", "yAxis")
      .attr("class", "axis")
      .call(yAxis); // Create an axis component with d3.axisLeft
  //gBY = leftPanel.append("g")
  //    .attr("id", "xBrush")
  //    .attr("class", "brush")
  //    .call(brushY);

  d3.select("#infoPanel").property("innerHTML", "\n")
}

initiate_plot()
draw()
    
// ################# definitions of functions #################

function update_axes() {
  // Update axes labels according to selected dimensions
  d3.select('#xlabel').text(xDim);
  d3.select('#ylabel').text(yDim);
  // Update scales according to selected diemnsions
  xScale.domain([d3.min(window.bounds[xDim],parseFloat),
                 d3.max(window.bounds[xDim],parseFloat)])

  yScale.domain([d3.min(window.bounds[yDim],parseFloat),
                 d3.max(window.bounds[yDim],parseFloat)])
  // Update an axis component according to selected dimensions
  xAxis = d3.axisBottom(xScale)
      .tickFormat(d => d == 0 ? "0" : (Math.abs(d) < 0.01 || Math.abs(d) >= 1000 ? d3.format(".2~e")(d) : d3.format(".3~r")(d)));
  gX.call(xAxis);
  yAxis = d3.axisLeft(yScale)
      .tickFormat(d => d == 0 ? "0" : (Math.abs(d) < 0.01 || Math.abs(d) >= 1000 ? d3.format(".2~e")(d) : d3.format(".3~r")(d)));
  gY.call(yAxis);
  // reset brushes
  //gBX.call(brushX.move, null);
  //gBY.call(brushY.move, null);
}

function handleMouseOver(d, i) {
  if(d3.select(this).attr("class") == "points") {
    var mouse = d3.mouse(this);
      
    xPos = (x => x == 0 ? "0" : (Math.abs(x) < 0.01 || Math.abs(x) >= 1000 ? d3.format(".2~e")(x) : d3.format(".3~r")(x)))(d[xDim])
    yPos = (x => x == 0 ? "0" : (Math.abs(x) < 0.01 || Math.abs(x) >= 1000 ? d3.format(".2~e")(x) : d3.format(".3~r")(x)))(d[yDim])
    feas = (x => x == 0 ? "0" : (Math.abs(x) < 0.01 || Math.abs(x) >= 1000 ? d3.format(".2~e")(x) : d3.format(".3~r")(x)))(d['Robustness'])
    
    //infoPanel_data = "Feasibility: "+(Math.abs(Number(d['Robustness'])) < 0.01 ? Number(d['Robustness']).toExponential(3) : Number(d['Robustness']).toFixed(4))+" at ["+xPos+","+yPos+"]";
    infoPanel_data = "Feasibility: "+feas+" at ["+xPos+","+yPos+"]";
  }
  d3.select("#infoPanel").property("innerHTML", infoPanel_data)
}

function handleMouseOut(d, i) {
  d3.select("#infoPanel").property("innerHTML", "\n")
}

function data_filter(d, i) {
  for(var idx in window.names) {
    var name = window.names[idx];
    var value_from_slider = Number(d3.select("#slider_"+name).property("value")); // index into list of unique values: window.uniqs
    if(name == xDim || name == yDim)  continue;
    
    if(Number(d[name]) != window.uniqs[name][value_from_slider]) return false;
    //else console.log(Number(d[name])+" vs. "+window.uniqs[name][value_from_slider]);
  }
  return true;
}

function draw() {
  
  d3.selectAll(".points").remove();     // because of the automatic redrawing of plot in response slider etc.

  var scheme_method = "d3.interpolateRdYlGn";
  var factor = 0;
  if (window.bounds['Robustness'][0] > 0) {
    scheme_method = "d3.interpolateYlGn";
  } else if (window.bounds['Robustness'][1] < 0) {
    scheme_method = "d3.interpolateYlOrRd";
    factor = 1;
  }

  container.selectAll(".points")
    .data(window.data)
    .enter()
    .filter(data_filter)
    .append("circle")
    .attr("class", "points")
    //.attr("id", d => d.id)
    .attr("cx", d => xScale(d[xDim]) )
    .attr("cy", d => yScale(d[yDim]) )
    .attr("r", radius )
    //.attr("fill", d => d3.interpolateRdYlGn((d['Robustness']*0.01 + 1)*0.5) )
    .attr("fill", d => Number(d['Robustness']) < gradient_middle ? eval(scheme_method)( Math.abs(negative_color_scale(Number(d['Robustness'])) - factor) ) : 
                                                     eval(scheme_method)( Math.abs(positive_color_scale(Number(d['Robustness'])) - factor) ) )
    //.attr("stroke", noColor )
    .attr("stroke-width", 0)
    .on("mouseover", handleMouseOver)
    .on("mouseout", handleMouseOut)
}

    </script>
  </body>

</html>
