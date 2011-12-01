//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require_tree .

function DrawPieChart(div_id, data, width, height, title) {
  var chart = new google.visualization.PieChart(document.getElementById(div_id));
  chart.draw(data, {width: width, height: height, title: title});
}

function DrawCoulmnChart(div_id, data, width, height, title, h_axis_title, v_axis_title) {
  var chart = new google.visualization.ColumnChart(document.getElementById(div_id));

  chart.draw(data, {width: width, height: height, title: title,
                    hAxis: {title: h_axis_title,
                            titleTextStyle: {color: 'black', fontSize: 16},
                            textStyle: {color: 'black', fontName: 'Arial Rounded MT Bold'}
                           },
                    vAxes:[{title: v_axis_title, titleTextStyle: {color: 'black', fontSize: 16}, textStyle:{color: 'black'}}]}
             );
}

function DrawLineChart(div_id, data, width, height, title, h_axis_title, v_axis_title, show_text_every, slanted_text, slanted_text_angle) {
  var chart = new google.visualization.LineChart(document.getElementById(div_id));

  chart.draw(data, {width: width, height: height, title: title,
                    hAxis: {title: h_axis_title, titleTextStyle: {color: 'black', fontSize: 16}, showTextEvery: show_text_every, slantedText: slanted_text, slantedTextAngle: slanted_text_angle},
                    vAxes:[{title: v_axis_title, titleTextStyle: {color: 'black', fontSize: 16}, textStyle:{color: 'black'}}]}
             );
}

