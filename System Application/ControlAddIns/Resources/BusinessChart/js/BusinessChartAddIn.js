/*! Copyright (C) Microsoft Corporation. All rights reserved. */
"use strict";

var chart = null,
  stackIndex;

// Taken from https://api.highcharts.com/highcharts/series.line.marker
var DEFAULT_MARKER_RADIUS = 4;
var HOVER_MARKER_RADIUS = DEFAULT_MARKER_RADIUS + 2;
// Cannot be 0 or highcharts will not render the marker and the point will not be accessible to screenreaders
var HIDDEN_MARKER_RADIUS = 0.0001;
// We do not provide a title for the chart, so modify the default "beforeChartFormat" screen reader text template to remove the <h5> containing the chart title. See #378209
// The original default template can be found here: https://api.highcharts.com/highcharts/accessibility.screenReaderSection.beforeChartFormat
var BEFORE_CHART_FORMAT_TEMPLATE =
  "<div>{typeDescription}</div><div>{chartSubtitle}</div><div>{chartLongdesc}</div><div>{playAsSoundButton}</div><div>{viewTableButton}</div><div>{xAxisDescription}</div><div>{yAxisDescription}</div><div>{annotationsTitle}{annotationsList}</div>";

// Initialization of the control add-in.
// Note: This function is called by the manifest after loading the control add-in.
function Initialize() {
  $(window).resize(function () {
    var width = $(this).width();
    var height = $(this).height();

    onChartSizeChanged(width, height);
  });

  raiseAddInReady();
}

// Update the chart with the supplied chart data.
// Note: This function is called from the application code.
function Update(chartData) {
  // If a tooltip from an existing chart is visible we must hide it
  if (chart != null && chart.tooltip != null && !chart.tooltip.isHidden) {
    // Start hiding it
    chart.tooltip.hide();

    // Wait for the tooltip's hide timer to fire
    // - otherwise we get a crash when the tooltip
    //   timer fires and references the tooltip,
    //   which would have been deleted before the
    //   timer fires if we don't wait for it.
    createUIWhenToolTipIsHidden(chartData);
  } else {
    createUI(chartData);
  }
}

// Refresh the control add-in.
function Refresh() {
  raiseRefresh();
}

// Event will be fired when the control add-in is ready for communication through its API.
function raiseAddInReady() {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("AddInReady", null);
}

// Event raised when the control add-in should be refreshed.
function raiseRefresh() {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Refresh", null);
}

// Event raised when a data point has been clicked.
function raiseDataPointClicked(point) {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
    "DataPointClicked",
    [point],
    true
  );
}

// Create a new chart and initialize it with the supplied data.
// If an existing chart is available, this function waits for the
// tooltip of the existing chart to be hidden before creating
// the new chart.
function createUIWhenToolTipIsHidden(chartData) {
  if (!chart.tooltip.isHidden) {
    window.setTimeout(function () {
      createUIWhenToolTipIsHidden(chartData);
      chartData = null;
    }, 100);
  } else {
    createUI(chartData);
  }
}

// Create a new chart and initialize it with the supplied data.
// If the data does not contain valid chart data it will create
// a text block showing a message about missing data instead of
// creating the chart.
function createUI(chartData) {
  if (chart != null) {
    chart.destroy();
    chart = null;
  }

  // Remove any existing content
  $("#controlAddIn").empty();

  if (validateChartData(chartData)) {
    initializeChartLanguage(chartData);
    createChart(chartData);
  }
}

// Verify that the chart data contains valid information.
function validateChartData(chartData) {
  if (!validateData(chartData)) {
    return false;
  }

  if (!validateYAxisRange(chartData)) {
    return false;
  }

  return true;
}

// Verify that the chart data contains data.
function validateData(chartData) {
  if (
    chartData.XDimensionColumn == null ||
    chartData.XDimensionColumn.ColumnName == null ||
    chartData.Measures == null ||
    chartData.Measures.length == 0 ||
    chartData.DataTable == null ||
    chartData.DataTable.length == 0 ||
    chartDataContainsEmptyPie(chartData)
  ) {
    createMessage(chartData.Resources.NoDataAvailable);
    return false;
  }

  return true;
}

// Verify that the chart data contains valid y-axis range.
function validateYAxisRange(chartData) {
  // Did we receive a valid y-axis range?
  if (
    !isNaN(chartData.YAxisMinimum) &&
    !isNaN(chartData.YAxisMaximum) &&
    chartData.YAxisMinimum >= chartData.YAxisMaximum
  ) {
    createMessage(chartData.Resources.YAxisRangeInvalid);
    return false;
  }

  return true;
}

// Create a DIV containing the specified message text.
function createMessage(text) {
  $("#controlAddIn").append(
    '<div class="' + getMessageClassName() + '"><span>' + text + "</span></div>"
  );
}

// Initialize the month, short month, and weekday names of the chart.
function initializeChartLanguage(chartData) {
  Highcharts.setOptions({
    lang: {
      months: chartData.Resources.MonthNames,
      shortMonths: chartData.Resources.ShortMonthNames,
      weekdays: chartData.Resources.WeekdayNames,
      accessibility: chartData.Resources.Accessibility,
    },
  });
}

function createPalette() {
  if (useModena365Theme()) {
    return [
      "rgba(80, 93, 109, 0.8)", // 1.  80% Ash grey
      "rgba(167, 173, 182, 0.8)", // 2.  80% Ash grey 50%
      "rgba(0, 128, 137, 0.8)", // 3.  80% Tertiary shade 2
      "rgba(0, 183, 195, 0.8)", // 4.  80% Aqua
      "rgba(166, 230, 234, 0.8)", // 5.  80% Aqua 35%
      "rgba(201, 196, 114, 0.8)", // 6.  80% Yellow
      "rgba(136, 206, 129, 0.8)", // 7.  80% Green
      "rgba(233, 119, 104, 0.8)", // 8.  80% Red
      "rgba(117, 181, 231, 0.8)", // 9.  80% Blue
      "rgba(133, 141, 153, 0.8)", // 10. 80% Ash grey 70%
      "rgba(229, 231, 233, 0.8)", // 11. 80% Ash grey 15%
      "rgba(89, 204, 180, 0.8)", // 12. 80% Light green
      "rgba(117, 216, 231, 0.8)", // 13. 80% Sky
      "rgba(238, 234, 134, 0.8)", // 14. 80% Egg
      "rgba(232, 158, 99, 0.8)", // 15. 80% Orange
      "rgba(219, 189, 235, 0.8)", // 16. 80% Violet
      "rgba(203, 206, 211, 0.8)", // 17. 80% Ash grey 30%
      "rgba(57, 178, 148, 0.8)", // 18. 80% Teal
      "rgba(115, 186, 90, 0.8)", // 19. 80% Green2
      "rgba(230, 94, 109, 0.8)", // 20. 80% Scarlet
    ];
  }

  return [
    "rgba(15, 111, 198, 0.8)", // 80% Blue
    "rgba(195, 38, 12, 0.8)", // 80% Red
    "rgba(84, 158, 57, 0.8)", // 80% Green
    "rgba(155, 87, 211, 0.8)", // 80% Purple
    "rgba(62, 204, 180, 0.8)", // 80% Turquoise
    "rgba(255, 185, 29, 0.8)", // 80% Yellow
    "rgba(180, 21, 109, 0.8)", // 80% Pink
    "rgba(255, 132, 39, 0.8)", // 80% Orange
    "rgba(177, 204, 41, 0.8)", // 80% Lime
    "rgba(41, 204, 82, 0.8)", // 80% Teal
    "rgba(36, 36, 102, 0.8)", // 80% DarkBlue
    "rgba(229, 115, 229, 0.8)", // 80% LightPurple
  ];
}

// Gets whether the tooltips should be enabled.
function getToolTipEnabled() {
  return true;
}

function getTooltipHeaderCaption(chartData) {
  var caption = chartData.XDimensionColumn.Caption;
  if (caption == null) {
    caption = chartData.XDimensionColumn.ColumnName;
  }

  return caption;
}

// Get the tooltip header format. A tooltip will contian one of
// these headers.
function getToolTipHeaderFormat(chartData) {
  var caption = getTooltipHeaderCaption(chartData);
  return (
    '<span class="addInToolTipHeader">' +
    caption +
    ": {point.key}</span><table>"
  );
}

// Get the tool tip point format. A tooltip will contain one of
// these for each serie in the chart.
function getToolTipPointFormat() {
  return (
    "<tr>" +
    '<td class="addInToolTipPointName"><span style="color:{series.color}">●</span> {series.name}: </td>' +
    '<td class="addInToolTipPointValue">{point.y}</td>' +
    "</tr>"
  );
}

// Get the tooltip footer format. A tooltip will contain one of
// these footers.
function getToolTipFooterFormat() {
  return "</table>";
}

// Create a new chart and initialize it with the supplied data.
function createChart(chartData) {
  stackIndex = 0;

  var xAxisType = getXAxisType(chartData);
  var legendEnabled = true;
  var verticalAlignmentLegend = getVerticalAlignmentLegend(chartData);
  chart = new Highcharts.Chart(
    {
      accessibility: {
        point: {
          descriptionFormatter: function (point) {
            var caption = getTooltipHeaderCaption(chartData);
            var value =
              point.series.type === "pie"
                ? Math.round(point.percentage) + "%"
                : point.y;

            return (
              caption +
              ": " +
              point.name +
              ", " +
              point.series.name +
              ": " +
              value
            );
          },
        },
        keyboardNavigation: {
          order: getKeyboardOrder(legendEnabled, verticalAlignmentLegend),
        },
        screenReaderSection: {
          beforeChartFormat: BEFORE_CHART_FORMAT_TEMPLATE,
        },
      },
      chart: {
        renderTo: "controlAddIn",
        type: getDefaultSerieType(chartData),
        polar: getPolarSeriesType(chartData),
      },
      colors: createPalette(),
      credits: {
        enabled: false,
      },
      exporting: {
        enabled: false,
      },
      legend: {
        align: getHorizontalAlignmentLegend(chartData),
        borderWidth: 0,
        enabled: legendEnabled,
        itemStyle: {
          fontWeight: "normal",
        },
        margin: 20,
        navigation: {
          style: {
            fontWeight: "normal",
          },
        },
        verticalAlign: verticalAlignmentLegend,
      },
      plotOptions: {
        area: {
          stacking: getAreaSeriesStacking(chartData),
          trackByArea: true,
        },
        column: {
          borderWidth: 1,
          groupPadding: 0.1,
          pointPadding: 0,
          stacking: getColumnSeriesStacking(chartData),
        },
        funnel: {
          dataLabels: {
            connectorWidth: 0,
            distance: 10,
          },
        },
        pie: {
          dataLabels: {
            connectorWidth: 0,
            distance: 10,
            enabled: false,
          },
          showInLegend: true,
        },
        series: {
          animation: true,
          cursor: "pointer",
          point: {
            events: {
              click: onPointClick,
              mouseOver: function () {
                var redrawChart = false;
                this.update(
                  {
                    color: this.color,
                  },
                  redrawChart
                );
              },
            },
          },
          stickyTracking: false,
        },
      },
      series: getSeries(chartData, xAxisType),
      title: {
        text: null,
      },
      tooltip: {
        enabled: getToolTipEnabled(),
        footerFormat: getToolTipFooterFormat(),
        headerFormat: getToolTipHeaderFormat(chartData),
        hideDelay: 0,
        pointFormat: getToolTipPointFormat(),
        backgroundColor: "rgba(247, 247, 247, .9)",
        borderWidth: 0,
        shared: true,
        useHTML: true,
      },
      xAxis: {
        minTickInterval: getXAxisMinTickInterval(xAxisType),
        type: xAxisType,
      },
      yAxis: {
        min: getYAxisMin(chartData),
        max: getYAxisMax(chartData),
        reversedStacks: false,
        title: {
          text: null,
        },
      },
    },
    function (chart) {
      var svgElement = chart.renderer.box;
      var descElements = svgElement.getElementsByTagName("desc");

      for (var i = descElements.length - 1; i >= 0; i--) {
        // This element says "Created by Highcharts Version <Version numbr>"
        // The element cannot be removed because the accessibility script references it
        // but the innerHTML can be cleared
        descElements[i].innerHTML = "";
      }
    }
  );

  // Make chart non-focusable
  $(chart.container).find("svg").attr("focusable", "false");

  var width = $(chart.container).width();
  var height = $(chart.container).height();

  // Update the size-dependent properties
  if (width > 0 && height > 0) {
    onSizeChanged(width, height);
  }
}

// Get the data series for the chart.
function getSeries(chartData, xAxisType) {
  var series = new Array();

  for (var i = 0; i < chartData.Measures.length; i++) {
    var measure = chartData.Measures[i];
    var stacking = getSerieStacking(chartData, measure);
    var stack;

    if (stacking != null) {
      stack = stacking;
    } else {
      stack = stackIndex++;
    }

    series[i] = {
      data: getSerieData(chartData, measure, xAxisType),
      innerSize: getSerieInnerSize(chartData, measure),
      lineWidth: getSerieLineWidth(chartData, measure),
      marker: getSerieMarker(chartData, measure),
      name: measure,
      stack: stack,
      step: getSerieLineStep(chartData, measure),
      type: getSerieType(chartData, measure),
    };
  }

  return series;
}

// Get the data of a single serie in the chart.
function getSerieData(chartData, measure, xAxisType) {
  var returnValue = new Array();
  for (var i = 0; i < chartData.DataTable.length; i++) {
    var data = chartData.DataTable[i][chartData.XDimensionColumn.ColumnName];
    if (xAxisType == "datetime") {
      returnValue[i] = {
        x: Date.parse(data),
        y: chartData.DataTable[i][measure],
      };
    } else {
      returnValue[i] = {
        name: data,
        y: chartData.DataTable[i][measure],
      };
    }
  }

  return returnValue;
}

// Get the default type (column, pie, etc) for the series in the chart.
function getDefaultSerieType(chartData) {
  return getChartType(chartData.DefaultType);
}

// Get the type (column, pie, etc) for a single serie in the chart.
function getSerieType(chartData, measure) {
  return getChartType(chartData.MeasureTypes[measure]);
}

// Get the chart type from the measure type of the chart data.
function getChartType(type) {
  switch (type) {
    case 0: // Point
    case 3: // Line
    case 5: // StepLine
      return "line";

    case 10: // Column
    case 11: // StackedColumn
    case 12: // StackedColumn100
      return "column";

    case 13: // Area
    case 15: // StackedArea
    case 16: // StackedArea100
      return "area";

    case 17: // Pie
    case 18: // Doughnut
      return "pie";

    case 25: // Radar
      return "area";

    case 33: // Funnel
      return "funnel";
  }

  throw "unsupported chart type";
}

// Get the stacking type of the first column serie that is using stacking.
function getColumnSeriesStacking(chartData) {
  for (var i = 0; i < chartData.Measures.length; i++) {
    var measure = chartData.Measures[i];
    var measureType = chartData.MeasureTypes[measure];
    switch (measureType) {
      case 11: // StackedColumn
      case 12: // StackedColumn100
        return getSerieStacking(chartData, chartData.Measures[i]);
    }
  }

  return null;
}

// Get the stacking type of the first area serie that is using stacking.
function getAreaSeriesStacking(chartData) {
  for (var i = 0; i < chartData.Measures.length; i++) {
    var measure = chartData.Measures[i];
    var measureType = chartData.MeasureTypes[measure];
    switch (measureType) {
      case 15: // StackedArea
      case 16: // StackedArea100
        return getSerieStacking(chartData, chartData.Measures[i]);
    }
  }

  return null;
}

// Get the stacking type of a single serie.
function getSerieStacking(chartData, measure) {
  var measureType = chartData.MeasureTypes[measure];
  switch (measureType) {
    case 11: // StackedColumn
    case 15: // StackedArea
      return "normal";

    case 12: // StackedColumn100
    case 16: // StackedArea100
      return "percent";
  }

  return null;
}

// Get the line width of a single serie. If not line is
// requested for the serie, 0 (zero) is returned.
function getSerieLineWidth(chartData, measure) {
  var measureType = chartData.MeasureTypes[measure];
  switch (measureType) {
    case 0: // Point
    case 13: // Area
    case 15: // StackedArea
    case 16: // StackedArea100
      return 0;
  }

  return 2;
}

// Get whether a single serie need line stepping.
// Only used for step line charts.
function getSerieLineStep(chartData, measure) {
  var measureType = chartData.MeasureTypes[measure];
  switch (measureType) {
    case 5: // StepLine
      return "left";
  }

  return false;
}

function getHideSerieMarker(chartData, measure) {
  var measureType = chartData.MeasureTypes[measure];
  switch (measureType) {
    case 0: // Point
      // You can't hide the markers on a point chart or you don't have a chart
      return false;
    default:
      return true;
  }
}

function getSerieMarker(chartData, measure) {
  var hideSerieMarker = getHideSerieMarker(chartData, measure);
  return {
    // This must be true, otherwise the screenreader cannot read the points
    // and we would need to find an alternative way to provide the information.
    enabled: true,
    states: {
      hover: {
        enabled: true,
        radius: HOVER_MARKER_RADIUS,
      },
    },
    // We cannot use the fill color to hide the marker because
    // the marker should be shown on hover, and if we override
    // the fill color in the normal state, we cannot set it back
    // to the "line color" in the hover state.
    // So instead, we manipulate the radius to hide the marker.
    radius: hideSerieMarker ? HIDDEN_MARKER_RADIUS : DEFAULT_MARKER_RADIUS,
  };
}

// Get the inner size of a serie.
// Only used for doughnut charts.
function getSerieInnerSize(chartData, measure) {
  var measureType = chartData.MeasureTypes[measure];
  switch (measureType) {
    case 18: // Doughnut
      return useModena365Theme() ? "65%" : "40%";
  }

  return 0;
}

// Get the polar type of the first serie that is using polar.
function getPolarSeriesType(chartData) {
  for (var i = 0; i < chartData.Measures.length; i++) {
    var polar = getPolarSerieType(chartData, chartData.Measures[i]);
    if (polar) {
      return polar;
    }
  }

  return false;
}

// Get the polar type of a single serie.
// Only used by radar charts.
function getPolarSerieType(chartData, measure) {
  var measureType = chartData.MeasureTypes[measure];
  switch (measureType) {
    case 25: // Radar
      return true;
  }

  return false;
}

// Get the x-axis type. For data-time data the x-axis is set as
// datetime. For all other types it is set to category.
function getXAxisType(chartData) {
  if (chartData.XDimensionColumn.DataType.indexOf("System.DateTime") == 0) {
    return "datetime";
  }

  return "category";
}

// Get the minimum tick interval of the x-axis.
// Only used by datetime x-axis chart types.
function getXAxisMinTickInterval(xAxisType) {
  if (xAxisType == "datetime") {
    return 24 * 3600 * 1000; // one day
  }

  return null;
}

// Get the minimum value of the y-axis.
function getYAxisMin(chartData) {
  if (!isNaN(chartData.YAxisMinimum)) {
    return chartData.YAxisMinimum;
  }

  return null;
}

// Get the maximum value of the y-axis.
function getYAxisMax(chartData) {
  if (!isNaN(chartData.YAxisMaximum)) {
    return chartData.YAxisMaximum;
  }

  return null;
}

// Gets the maximum number of label lines on the x-axis.
function getXAxisLabelsMaxStaggerLines(height) {
  if (height < 260) {
    return 1;
  }

  if (height < 320) {
    return 2;
  }

  if (height < 380) {
    return 3;
  }

  return 4;
}

// Updates the x-axis labels settings that are dependent
// on the size of the chart.
function updateXAxisLabels(width, height) {
  var staggerLines = getXAxisLabelsMaxStaggerLines(height);

  var xAxisLabelsMaxStaggerLines = staggerLines > 1 ? staggerLines : null;
  var xAxisStaggerLines = staggerLines <= 1 ? staggerLines : null;

  // When updating the x-axis the labels get cleared, so we
  // must get a copy of the label before updating the x-axis
  var names = chart.xAxis[0].names;

  chart.xAxis[0].update(
    {
      labels: {
        staggerLines: xAxisStaggerLines,
        maxStaggerLines: xAxisLabelsMaxStaggerLines,
        overflow: "justify",
      },
    },
    false
  );

  // And now we can restore the labels on the x-axis
  chart.xAxis[0].names = names;
}

// Updates the legend settings that are dependent
// on the size of the chart.
function updateLegend(width, height) {
  var enableLegend = getEnableLegend(width, height);
  if (chart.options.legend["enabled"] != enableLegend) {
    chart.options.legend["enabled"] = enableLegend;
    chart.legend["enabled"] = enableLegend;
    chart.legend["display"] = enableLegend;

    var keyboardOrder = getKeyboardOrder(
      enableLegend,
      chart.legend.verticalAlign
    );
    chart.accessibility.keyboardNavigation["order"] = keyboardOrder;
    chart.options.accessibility.keyboardNavigation["order"] = keyboardOrder;

    for (var i = 0; i < chart.series.length; i++) {
      chart.series[i].update(
        {
          showInLegend: enableLegend,
        },
        false
      );

      // On pie charts we also need to disable the
      // data labels when showing the legend
      if (chart.series[i].type == "pie") {
        chart.series[i].update(
          {
            dataLabels: {
              enabled: !enableLegend,
            },
          },
          false
        );
      }
    }
  }

  // Highcharts does not recreate the legend accessibility proxies when enabled changes, so force it
  chart.options.legend.accessibility.enabled = enableLegend;
  chart.accessibility.components.legend.recreateProxies();
  chart.accessibility.components.legend.updateLegendTitle();
}

// Determine whether the chart contains a pie.
function chartContainsPie() {
  for (var i = 0; i < chart.series.length; i++) {
    if (chart.series[i].type == "pie") {
      return true;
    }
  }

  return false;
}

// Determine whether the chart data contains a pie.
function chartDataContainsPie(chartData) {
  for (var i = 0; i < chartData.Measures.length; i++) {
    if (getSerieType(chartData, chartData.Measures[i]) == "pie") {
      return true;
    }
  }

  return false;
}

// Determine whether the chart data contains an empty pie, i.e.
// a pie chart where all the values are zero.
function chartDataContainsEmptyPie(chartData) {
  var xAxisType = getXAxisType(chartData);

  for (var i = 0; i < chartData.Measures.length; i++) {
    var chartType = getSerieType(chartData, chartData.Measures[i]);

    if (chartType == "pie") {
      var data = getSerieData(chartData, chartData.Measures[i], xAxisType);

      for (var j = 0; j < data.length; j++) {
        var value = data[j].y;
        if (value != 0) {
          return false;
        }
      }

      return true;
    }
  }

  return false;
}

// Get whether the legend should be enabled.
function getEnableLegend(width, height) {
  return (
    getSeriesEnableLegend(width, height) || getPieEnableLegend(width, height)
  );
}

// Get whether the legend should be enabled for series.
function getSeriesEnableLegend(width, height) {
  // There is only one serie - no legend needed
  if (chart.series.length <= 1) {
    return false;
  }

  // If we have little height and tooltips are
  // enabled then hide the legend
  return height > 200 || !getToolTipEnabled();
}

// Gets whether the legend should be enabled on pie.
function getPieEnableLegend(width, height) {
  if (!chartContainsPie()) {
    return false;
  }

  // Use legend on pie if there is not room for data labels on the pie
  return width < 480 || (4 / 3) * height > width /*portrait*/;
}

// Gets the horizontal alignment of the legend.
function getHorizontalAlignmentLegend(chartData) {
  // Setting the horizontal alignment property when creating the chart is broken in
  // Highcharts 4.0.1, so instead we are using a CSS style for fixing the alignment.
  if (
    useModena365Theme() &&
    getVerticalAlignmentLegend(chartData) !== "bottom"
  ) {
    document.body.classList.add("left-align-legend");
  } else {
    document.body.classList.remove("left-align-legend");
  }

  return "center";
}

// Gets the vertical alignment of the legend.
function getVerticalAlignmentLegend(chartData) {
  // Show legend at the bottom for pie chart on the phone
  if (
    chartDataContainsPie(chartData) &&
    Microsoft.Dynamics.NAV.GetEnvironment().DeviceCategory == 2
  ) {
    return "bottom";
  }

  return "top";
}

function getKeyboardOrder(legendEnabled, verticalAlignmentLegend) {
  if (!legendEnabled) {
    return ["series"];
  }

  return verticalAlignmentLegend === "top"
    ? ["legend", "series"]
    : ["series", "legend"];
}

// Event handler called when the size of the chart is changed.
function onChartSizeChanged(width, height) {
  if (chart == null || height <= 0 || width <= 0) {
    return;
  }

  // Does the chart already have the requested size?
  var c = chart.xAxis[0].chart;
  if (c != null && c.chartHeight == height && c.chartHeight == height) {
    return;
  }

  onSizeChanged(width, height);
}

function onSizeChanged(width, height) {
  updateXAxisLabels(width, height);
  updateLegend(width, height);

  // Now make the chart recalculate the sizes
  // used for legend and chart. Setting the size
  // also triggers a redraw of the chart.
  chart.setSize();
}

// Event handler called when a point in the chart is clicked.
function onPointClick() {
  var xValueString;

  // use "this" instead of the received event object because the event object has
  // a different structure based on whether the event was activated by mouse or
  // keyboard. "this" is the same object regardless of activation method.
  var point = this;

  if (typeof point.name != "undefined") {
    xValueString = point.name;
  } else {
    // It is a date - we need to return the number of days since 31 Dec 1899
    // as the GetDateString function in Table 485 Business Chart Buffer
    // expects this.
    var timezone = new Date().getTimezoneOffset();
    var daysSince1970 = (point.x / (60 * 1000) - timezone) / (60 * 24);
    var daysSince1900 = daysSince1970 + 25569;
    xValueString = Math.round(daysSince1900 * 10) / 10;
  }

  raiseDataPointClicked({
    Measures: [point.series.name],
    XValueString: xValueString,
    YValues: [point.y],
  });
}

function isNaN(number) {
  return number == "NaN";
}

function getMessageClassName() {
  return "addInMessage" + getClassNameSuffix();
}

function getClassNameSuffix() {
  switch (Microsoft.Dynamics.NAV.GetEnvironment().DeviceCategory) {
    case 0:
    default:
      return "-desktop";
    case 1:
      return "-tablet";
    case 2:
      return "-phone";
  }
}

function useModena365Theme() {
  return document.body.classList.contains("theme-m365");
}

// SIG // Begin signature block
// SIG // MIIoKgYJKoZIhvcNAQcCoIIoGzCCKBcCAQExDzANBglg
// SIG // hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
// SIG // BgEEAYI3AgEeMCQCAQEEEBDgyQbOONQRoqMAEEvTUJAC
// SIG // AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
// SIG // NFeSPv9ayPyB1LF/TlhOagPxp/8/ZJHaDsiq3tQBk7Cg
// SIG // gg12MIIF9DCCA9ygAwIBAgITMwAABIVemewOWS/N1wAA
// SIG // AAAEhTANBgkqhkiG9w0BAQsFADB+MQswCQYDVQQGEwJV
// SIG // UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
// SIG // UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
// SIG // cmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29kZSBT
// SIG // aWduaW5nIFBDQSAyMDExMB4XDTI1MDYxOTE4MjEzN1oX
// SIG // DTI2MDYxNzE4MjEzN1owdDELMAkGA1UEBhMCVVMxEzAR
// SIG // BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
// SIG // bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
// SIG // bjEeMBwGA1UEAxMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
// SIG // MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
// SIG // wEpIdXKb7lKn26sXpXuywkhxGplTQXxROLmNRZBrAHVB
// SIG // f7546RNXZwA/bzDqsuWTuPSC4T+I4j/z9j5/WqPuUw7S
// SIG // pnEPqWXc2xu7eN8kVyQt5170xkK6KHT4vVEkIvayPtIM
// SIG // Ll0SgSCOy/pN5DJCi5ha7FlI84F1Qi2GumR+wQgCwHCV
// SIG // mU8Fj6Ik+B6akISXGCwe6X3rQFQngRFWQ/IrSkOkAOfy
// SIG // 0EfvV+nZUo+FcbWuCZ6cb4Eq5I1ws/rZSeuwAWeedZcN
// SIG // t0VlNbsn4AnxBYQX4sj0dlko7JD5fWqeqq3/HzUNbBmL
// SIG // p9qeCXV8XlACn9YVWv900F47z04kVwpyTwIDAQABo4IB
// SIG // czCCAW8wHwYDVR0lBBgwFgYKKwYBBAGCN0wIAQYIKwYB
// SIG // BQUHAwMwHQYDVR0OBBYEFLgmchogri2BNGlO4+UxamNO
// SIG // ZJKNMEUGA1UdEQQ+MDykOjA4MR4wHAYDVQQLExVNaWNy
// SIG // b3NvZnQgQ29ycG9yYXRpb24xFjAUBgNVBAUTDTIzMDAx
// SIG // Mis1MDUzNTkwHwYDVR0jBBgwFoAUSG5k5VAF04KqFzc3
// SIG // IrVtqMp1ApUwVAYDVR0fBE0wSzBJoEegRYZDaHR0cDov
// SIG // L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWlj
// SIG // Q29kU2lnUENBMjAxMV8yMDExLTA3LTA4LmNybDBhBggr
// SIG // BgEFBQcBAQRVMFMwUQYIKwYBBQUHMAKGRWh0dHA6Ly93
// SIG // d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMvTWlj
// SIG // Q29kU2lnUENBMjAxMV8yMDExLTA3LTA4LmNydDAMBgNV
// SIG // HRMBAf8EAjAAMA0GCSqGSIb3DQEBCwUAA4ICAQAo5qgK
// SIG // dgouLEx2XIvqpLRACrBZORzVRislkdqxRl7He3IIGdOB
// SIG // +VOEldHwC+nzhPXS77eCOxwRy4aRnROVIy8uDcS0xtmw
// SIG // wJHgFZsZndrillRisptWmqw8V379xgjeJkV/j5+HPqct
// SIG // 0v+ipLeXkgwCCLK8ysNyodkltYQsF1/5Nb+G/jR9RY5f
// SIG // ov8TybKVwhbmQeGguRS0+X4G0Sqp7FngHZ/A7K2EIU90
// SIG // Fy7ejb9/3TM7+xvwnaW3XKLpfBWJfrd3ZlzPkiApQt5d
// SIG // mntMDpTa0ONskBMnLj1OTqKi0/OY7Ge/uAmknHxSDZTu
// SIG // 5e2O6/8Wrqh20j0Na96CAvnu9ebNhtwpWWt8vfWmMdpZ
// SIG // 12HtbK3KyMfDQF01YosqV1Z/WRphJHzXHw4qhkMJJpec
// SIG // /Z5t6VogWevWnWgQWwBRI8iRuMtGu+m3pf+LAwlb2mcy
// SIG // zN0xW8VTvQUK42UbWyWW5At1wK6S6mUn8ed0rmHXXcT1
// SIG // /Kb3KhbhLvMHFHg9ObfcTWyeE7XQBAiZRItL7wcZZjOb
// SIG // cxV8tqmXqjzFx0kGKj4GfY70nGejcM5xQ9Pt95G88oTk
// SIG // s/1rhmwLuHB2RvICp5UFU+LgNg4nsfQzLNlh4qJDZJ2J
// SIG // S6FHll1tUKyS6ajvNky8ik2wTP6GRwHSHNJM6Ek66PW9
// SIG // /r459vNPQ9PkjjglWTCCB3owggVioAMCAQICCmEOkNIA
// SIG // AAAAAAMwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYT
// SIG // AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
// SIG // EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
// SIG // cG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290
// SIG // IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDExMB4XDTEx
// SIG // MDcwODIwNTkwOVoXDTI2MDcwODIxMDkwOVowfjELMAkG
// SIG // A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAO
// SIG // BgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
// SIG // dCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9zb2Z0
// SIG // IENvZGUgU2lnbmluZyBQQ0EgMjAxMTCCAiIwDQYJKoZI
// SIG // hvcNAQEBBQADggIPADCCAgoCggIBAKvw+nIQHC6t2G6q
// SIG // ghBNNLrytlghn0IbKmvpWlCquAY4GgRJun/DDB7dN2vG
// SIG // EtgL8DjCmQawyDnVARQxQtOJDXlkh36UYCRsr55JnOlo
// SIG // XtLfm1OyCizDr9mpK656Ca/XllnKYBoF6WZ26DJSJhIv
// SIG // 56sIUM+zRLdd2MQuA3WraPPLbfM6XKEW9Ea64DhkrG5k
// SIG // NXimoGMPLdNAk/jj3gcN1Vx5pUkp5w2+oBN3vpQ97/vj
// SIG // K1oQH01WKKJ6cuASOrdJXtjt7UORg9l7snuGG9k+sYxd
// SIG // 6IlPhBryoS9Z5JA7La4zWMW3Pv4y07MDPbGyr5I4ftKd
// SIG // gCz1TlaRITUlwzluZH9TupwPrRkjhMv0ugOGjfdf8NBS
// SIG // v4yUh7zAIXQlXxgotswnKDglmDlKNs98sZKuHCOnqWbs
// SIG // YR9q4ShJnV+I4iVd0yFLPlLEtVc/JAPw0XpbL9Uj43Bd
// SIG // D1FGd7P4AOG8rAKCX9vAFbO9G9RVS+c5oQ/pI0m8GLhE
// SIG // fEXkwcNyeuBy5yTfv0aZxe/CHFfbg43sTUkwp6uO3+xb
// SIG // n6/83bBm4sGXgXvt1u1L50kppxMopqd9Z4DmimJ4X7Iv
// SIG // hNdXnFy/dygo8e1twyiPLI9AN0/B4YVEicQJTMXUpUMv
// SIG // dJX3bvh4IFgsE11glZo+TzOE2rCIF96eTvSWsLxGoGyY
// SIG // 0uDWiIwLAgMBAAGjggHtMIIB6TAQBgkrBgEEAYI3FQEE
// SIG // AwIBADAdBgNVHQ4EFgQUSG5k5VAF04KqFzc3IrVtqMp1
// SIG // ApUwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYD
// SIG // VR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0j
// SIG // BBgwFoAUci06AjGQQ7kUBU7h6qfHMdEjiTQwWgYDVR0f
// SIG // BFMwUTBPoE2gS4ZJaHR0cDovL2NybC5taWNyb3NvZnQu
// SIG // Y29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0
// SIG // MjAxMV8yMDExXzAzXzIyLmNybDBeBggrBgEFBQcBAQRS
// SIG // MFAwTgYIKwYBBQUHMAKGQmh0dHA6Ly93d3cubWljcm9z
// SIG // b2Z0LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0MjAx
// SIG // MV8yMDExXzAzXzIyLmNydDCBnwYDVR0gBIGXMIGUMIGR
// SIG // BgkrBgEEAYI3LgMwgYMwPwYIKwYBBQUHAgEWM2h0dHA6
// SIG // Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvZG9jcy9w
// SIG // cmltYXJ5Y3BzLmh0bTBABggrBgEFBQcCAjA0HjIgHQBM
// SIG // AGUAZwBhAGwAXwBwAG8AbABpAGMAeQBfAHMAdABhAHQA
// SIG // ZQBtAGUAbgB0AC4gHTANBgkqhkiG9w0BAQsFAAOCAgEA
// SIG // Z/KGpZjgVHkaLtPYdGcimwuWEeFjkplCln3SeQyQwWVf
// SIG // Liw++MNy0W2D/r4/6ArKO79HqaPzadtjvyI1pZddZYSQ
// SIG // fYtGUFXYDJJ80hpLHPM8QotS0LD9a+M+By4pm+Y9G6XU
// SIG // tR13lDni6WTJRD14eiPzE32mkHSDjfTLJgJGKsKKELuk
// SIG // qQUMm+1o+mgulaAqPyprWEljHwlpblqYluSD9MCP80Yr
// SIG // 3vw70L01724lruWvJ+3Q3fMOr5kol5hNDj0L8giJ1h/D
// SIG // Mhji8MUtzluetEk5CsYKwsatruWy2dsViFFFWDgycSca
// SIG // f7H0J/jeLDogaZiyWYlobm+nt3TDQAUGpgEqKD6CPxNN
// SIG // ZgvAs0314Y9/HG8VfUWnduVAKmWjw11SYobDHWM2l4bf
// SIG // 2vP48hahmifhzaWX0O5dY0HjWwechz4GdwbRBrF1HxS+
// SIG // YWG18NzGGwS+30HHDiju3mUv7Jf2oVyW2ADWoUa9WfOX
// SIG // pQlLSBCZgB/QACnFsZulP0V3HjXG0qKin3p6IvpIlR+r
// SIG // +0cjgPWe+L9rt0uX4ut1eBrs6jeZeRhL/9azI2h15q/6
// SIG // /IvrC4DqaTuv/DDtBEyO3991bWORPdGdVk5Pv4BXIqF4
// SIG // ETIheu9BCrE/+6jMpF3BoYibV3FWTkhFwELJm3ZbCoBI
// SIG // a/15n8G9bW1qyVJzEw16UM0xghoMMIIaCAIBATCBlTB+
// SIG // MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
// SIG // bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
// SIG // cm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNy
// SIG // b3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExAhMzAAAE
// SIG // hV6Z7A5ZL83XAAAAAASFMA0GCWCGSAFlAwQCAQUAoIGu
// SIG // MBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisG
// SIG // AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3
// SIG // DQEJBDEiBCA4wKfwIvf0QcGSB1D9tlGezvL7v0F4APDy
// SIG // swebHhK7zTBCBgorBgEEAYI3AgEMMTQwMqAUgBIATQBp
// SIG // AGMAcgBvAHMAbwBmAHShGoAYaHR0cDovL3d3dy5taWNy
// SIG // b3NvZnQuY29tMA0GCSqGSIb3DQEBAQUABIIBABdWWw54
// SIG // T54Rh0iAJ3Oe9AefgCPwffCqDLDPHiJHIHT5Dg60p+Pq
// SIG // AEHrdz+CIRALCiZcz9DmfYA3MXvWw/dKEhl499JkTr1k
// SIG // 9Mylap+vd80mbNPq29AlWWLujBvJMhEZTOUwq10oRYyU
// SIG // 3hu22Rl7FTMVHfTrU3cCD/73jS7oXf1KShJZukrQIOQG
// SIG // CXjdGC58OAxZzJtS/jM6/9qrvRjU4ufx1MdNwdwS47xE
// SIG // lR0hgGLWj6XD9u2z9ar6aKyC70qGvLTnWXq02L94Fehk
// SIG // CTSrtPsvXfEOWLrvb5BtHzjltiW7O0AEMDC5TxUJ85WT
// SIG // TO0CBYAltgpW+H0c83zUpzwRSPOhgheWMIIXkgYKKwYB
// SIG // BAGCNwMDATGCF4Iwghd+BgkqhkiG9w0BBwKgghdvMIIX
// SIG // awIBAzEPMA0GCWCGSAFlAwQCAQUAMIIBUgYLKoZIhvcN
// SIG // AQkQAQSgggFBBIIBPTCCATkCAQEGCisGAQQBhFkKAwEw
// SIG // MTANBglghkgBZQMEAgEFAAQg38w/SUxAx98jsupT5Yun
// SIG // 8r0mn43etFDGICeddZwOtvACBmnBTIjSCxgTMjAyNjA0
// SIG // MDEyMDM3NTQuODQyWjAEgAIB9KCB0aSBzjCByzELMAkG
// SIG // A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAO
// SIG // BgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
// SIG // dCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0
// SIG // IEFtZXJpY2EgT3BlcmF0aW9uczEnMCUGA1UECxMeblNo
// SIG // aWVsZCBUU1MgRVNOOkRDMDAtMDVFMC1EOTQ3MSUwIwYD
// SIG // VQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNl
// SIG // oIIR7DCCByAwggUIoAMCAQICEzMAAAIkO4QhsCysZCIA
// SIG // AQAAAiQwDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMC
// SIG // VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
// SIG // B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
// SIG // b3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUt
// SIG // U3RhbXAgUENBIDIwMTAwHhcNMjYwMjE5MTkzOTU5WhcN
// SIG // MjcwNTE3MTkzOTU5WjCByzELMAkGA1UEBhMCVVMxEzAR
// SIG // BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
// SIG // bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
// SIG // bjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3Bl
// SIG // cmF0aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNO
// SIG // OkRDMDAtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3Nv
// SIG // ZnQgVGltZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkqhkiG
// SIG // 9w0BAQEFAAOCAg8AMIICCgKCAgEAo+lt1GkNma+ITb0s
// SIG // u4+1DDxVcrO2hMRgfiRcMpM814N42smJvYDi1ye7TYVN
// SIG // npoay0AjmXIC78+hZKpoIc0Mc5pICrS2IimhM4aIDv3H
// SIG // tJU4XSzXVbTMEDmIKPl7VwGXFYgV+C3B5N/EbrGYhe8M
// SIG // Umubfy8YnNOPmf4ZctYCUKSHhQ6qeGvT7i7fK7Hx9Ob1
// SIG // vaVPbq4hnQ8XyV5/5XOPQsW16gNxF9ey9uG3Orfphbjw
// SIG // wCSiqWot116hdpyZaUz33awNvbFk0jSooPQrQQubc0I9
// SIG // H5W7Gv+MKjvbvkZLsKWW92+6p1uRXRaw0db0Jl345clD
// SIG // /WTt/PN/TcEroh7b7BQjZEzSF/Di+V1atZ7Csrv/xniG
// SIG // fWLsbHywXnahtNuDwxEcqwLNKb31Fji2qVUGoxz6Ap7j
// SIG // Uir2xIe7OSENGILqRo4vh+6yA8dv5iBCPukPFsAbZN2M
// SIG // coY49Bl8PdPYtBJE5FcsvtcgA48EgvG8NqjOPjHOIcsr
// SIG // ZWc0nNCD1AatWBp2MAoyMGuf5TFtKRZ/x6SXQel3jLk7
// SIG // WEzqWj6KOuBY0K8i11o3eKL6cOZTsO1/r9xPZMDfVQQv
// SIG // sCREgRAgtYGTAkuU2lcHxNcOKZ1129ak/W44EbD4OHZJ
// SIG // a7lE3aJ/90jbdGtEOTXNlJfqzJUMV6D/YrF8DDZyjuSS
// SIG // ZKkQ0VUCAwEAAaOCAUkwggFFMB0GA1UdDgQWBBRzH5F9
// SIG // bv8ySwjHtIKmIrcdbQB3qDAfBgNVHSMEGDAWgBSfpxVd
// SIG // AF5iXYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQ
// SIG // hk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3Bz
// SIG // L2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENB
// SIG // JTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwG
// SIG // CCsGAQUFBzAChlBodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
// SIG // b20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUt
// SIG // U3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMB
// SIG // Af8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMA4G
// SIG // A1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsFAAOCAgEA
// SIG // PsB0m5oSKTPAkVWeLZOtuIUPi3WVxOKqHkLou+wnjWt4
// SIG // 6tRTs4uzESpJKOnYhAx1zzVrwGoMWrLQnsD85uUwjYdb
// SIG // OKgh4eEdhv6+PMFPzKXOvP1g5icuQiEJ/xcKbNbGzVBL
// SIG // uwc4NNOKlCyFSfet46P2puMcCoMIfr0lS+/3YbH0+3b4
// SIG // aUXXW2C0Ex2YMLjQekIXBBLIKIC1cDUY9+1RFmQ4sKDH
// SIG // ccgu2GK0LujAlbYsx5zrZEl+xaiKIuo5XH6n6Otfbgx/
// SIG // a/JNqgDhwnhAKilyspiFwzHBhpRHQxW2Ig2YDwgTNCB4
// SIG // AHopVEqJ9O8Ix7tHtLLAZrQWnz2+BnfuRbkZ1ht1xnvd
// SIG // TQqSyqphWv+BpFc/TjM2VIPKHM8Qv+CU9x3+OSRLbM06
// SIG // F8DbJFdyTQnLtiCLa+kiR5otxA1QAw0UjYXcxUaWJqZR
// SIG // hJT5eRkaD7SYgxL0SG7+TBSiMNsfYJ3oX+SLwYwuGZAY
// SIG // PuBk6ahhN5pp8xd5yHpDpF+LoNP9Jjdgkmq4bkovTZhy
// SIG // DqVDdnkB1LYE2//hpqu4JLQjMCKvyTgmCIk2Kqb9aG4w
// SIG // BinVjDwq5UsjQLNI2WM5IWud+defDTMfsARr7HxaFbAj
// SIG // BuTnKer1ugl8rlkW1FajFNTq0Gx33csyaW4SQtT2wGSM
// SIG // iQmzflQYA0wM0ymPMOCEksEwggdxMIIFWaADAgECAhMz
// SIG // AAAAFcXna54Cm0mZAAAAAAAVMA0GCSqGSIb3DQEBCwUA
// SIG // MIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
// SIG // Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
// SIG // TWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylN
// SIG // aWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3Jp
// SIG // dHkgMjAxMDAeFw0yMTA5MzAxODIyMjVaFw0zMDA5MzAx
// SIG // ODMyMjVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
// SIG // YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
// SIG // VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
// SIG // BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
// SIG // MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
// SIG // 5OGmTOe0ciELeaLL1yR5vQ7VgtP97pwHB9KpbE51yMo1
// SIG // V/YBf2xK4OK9uT4XYDP/XE/HZveVU3Fa4n5KWv64NmeF
// SIG // RiMMtY0Tz3cywBAY6GB9alKDRLemjkZrBxTzxXb1hlDc
// SIG // wUTIcVxRMTegCjhuje3XD9gmU3w5YQJ6xKr9cmmvHaus
// SIG // 9ja+NSZk2pg7uhp7M62AW36MEBydUv626GIl3GoPz130
// SIG // /o5Tz9bshVZN7928jaTjkY+yOSxRnOlwaQ3KNi1wjjHI
// SIG // NSi947SHJMPgyY9+tVSP3PoFVZhtaDuaRr3tpK56KTes
// SIG // y+uDRedGbsoy1cCGMFxPLOJiss254o2I5JasAUq7vnGp
// SIG // F1tnYN74kpEeHT39IM9zfUGaRnXNxF803RKJ1v2lIH1+
// SIG // /NmeRd+2ci/bfV+AutuqfjbsNkz2K26oElHovwUDo9Fz
// SIG // pk03dJQcNIIP8BDyt0cY7afomXw/TNuvXsLz1dhzPUNO
// SIG // wTM5TI4CvEJoLhDqhFFG4tG9ahhaYQFzymeiXtcodgLi
// SIG // Mxhy16cg8ML6EgrXY28MyTZki1ugpoMhXV8wdJGUlNi5
// SIG // UPkLiWHzNgY1GIRH29wb0f2y1BzFa/ZcUlFdEtsluq9Q
// SIG // BXpsxREdcu+N+VLEhReTwDwV2xo3xwgVGD94q0W29R6H
// SIG // XtqPnhZyacaue7e3PmriLq0CAwEAAaOCAd0wggHZMBIG
// SIG // CSsGAQQBgjcVAQQFAgMBAAEwIwYJKwYBBAGCNxUCBBYE
// SIG // FCqnUv5kxJq+gpE8RjUpzxD/LwTuMB0GA1UdDgQWBBSf
// SIG // pxVdAF5iXYP05dJlpxtTNRnpcjBcBgNVHSAEVTBTMFEG
// SIG // DCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNodHRw
// SIG // Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3Mv
// SIG // UmVwb3NpdG9yeS5odG0wEwYDVR0lBAwwCgYIKwYBBQUH
// SIG // AwgwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYD
// SIG // VR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0j
// SIG // BBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0f
// SIG // BE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQu
// SIG // Y29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0
// SIG // XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBK
// SIG // BggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQu
// SIG // Y29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0w
// SIG // Ni0yMy5jcnQwDQYJKoZIhvcNAQELBQADggIBAJ1Vffwq
// SIG // reEsH2cBMSRb4Z5yS/ypb+pcFLY+TkdkeLEGk5c9MTO1
// SIG // OdfCcTY/2mRsfNB1OW27DzHkwo/7bNGhlBgi7ulmZzpT
// SIG // Td2YurYeeNg2LpypglYAA7AFvonoaeC6Ce5732pvvinL
// SIG // btg/SHUB2RjebYIM9W0jVOR4U3UkV7ndn/OOPcbzaN9l
// SIG // 9qRWqveVtihVJ9AkvUCgvxm2EhIRXT0n4ECWOKz3+SmJ
// SIG // w7wXsFSFQrP8DJ6LGYnn8AtqgcKBGUIZUnWKNsIdw2Fz
// SIG // Lixre24/LAl4FOmRsqlb30mjdAy87JGA0j3mSj5mO0+7
// SIG // hvoyGtmW9I/2kQH2zsZ0/fZMcm8Qq3UwxTSwethQ/gpY
// SIG // 3UA8x1RtnWN0SCyxTkctwRQEcb9k+SS+c23Kjgm9swFX
// SIG // SVRk2XPXfx5bRAGOWhmRaw2fpCjcZxkoJLo4S5pu+yFU
// SIG // a2pFEUep8beuyOiJXk+d0tBMdrVXVAmxaQFEfnyhYWxz
// SIG // /gq77EFmPWn9y8FBSX5+k77L+DvktxW/tM4+pTFRhLy/
// SIG // AsGConsXHRWJjXD+57XQKBqJC4822rpM+Zv/Cuk0+CQ1
// SIG // ZyvgDbjmjJnW4SLq8CdCPSWU5nR0W2rRnj7tfqAxM328
// SIG // y+l7vzhwRNGQ8cirOoo6CGJ/2XBjU02N7oJtpQUQwXEG
// SIG // ahC0HVUzWLOhcGbyoYIDTzCCAjcCAQEwgfmhgdGkgc4w
// SIG // gcsxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
// SIG // dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
// SIG // aWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1p
// SIG // Y3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMxJzAlBgNV
// SIG // BAsTHm5TaGllbGQgVFNTIEVTTjpEQzAwLTA1RTAtRDk0
// SIG // NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAg
// SIG // U2VydmljZaIjCgEBMAcGBSsOAwIaAxUApgjx25rHgEn3
// SIG // v/2xrV/XkBvtPuOggYMwgYCkfjB8MQswCQYDVQQGEwJV
// SIG // UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
// SIG // UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
// SIG // cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1T
// SIG // dGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQsFAAIFAO13
// SIG // pw0wIhgPMjAyNjA0MDExNDE1NDFaGA8yMDI2MDQwMjE0
// SIG // MTU0MVowdjA8BgorBgEEAYRZCgQBMS4wLDAKAgUA7Xen
// SIG // DQIBADAJAgEAAgFiAgH/MAcCAQACAhN1MAoCBQDtePiN
// SIG // AgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkK
// SIG // AwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZI
// SIG // hvcNAQELBQADggEBAFTaG4tXlcGYA/zwShYHzljrtAV0
// SIG // /hWzipAutV2gxIUBXsWINvuTm5BM8lhVxc2fSN6UmZg1
// SIG // 98JXVXauYlhrrNC3coYBt/b8qFeZFkzP7ekIIFPGCmDh
// SIG // ortDkXn/YYznjtRBXxk36qYscisB3ktJEQ5fcUnpg4gA
// SIG // aDtQgHXg0VV7A2DNskwQCM4Njz/Mw7AWwwn+hovErlvC
// SIG // VtlsxfoXWZnlUnn3nhAFDFSpDNIUCY6p7llPrEeR+NN2
// SIG // p6p/ftP5D1mUWFXfkt0VYvQnf7XnztaKLzha+LPpeHCw
// SIG // DaLtjgkyKtbM7uI22oalJxR1Pix6INyM48Nx0CvLcxkC
// SIG // Ssu4zS0xggQNMIIECQIBATCBkzB8MQswCQYDVQQGEwJV
// SIG // UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
// SIG // UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
// SIG // cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1T
// SIG // dGFtcCBQQ0EgMjAxMAITMwAAAiQ7hCGwLKxkIgABAAAC
// SIG // JDANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkD
// SIG // MQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCAL
// SIG // bbIBuRRpyjq9nHBEfUGnhgo0Eg70eQXf1NMzI4VvdzCB
// SIG // +gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIEghPTdq
// SIG // m/dRyZ0BczXcdloVEqICdcmpVNbH9CEVzWSOMIGYMIGA
// SIG // pH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
// SIG // bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
// SIG // FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMd
// SIG // TWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMA
// SIG // AAIkO4QhsCysZCIAAQAAAiQwIgQg2GfgaCeXMYKrfqUz
// SIG // U/qRFktUcomtbQKK6TMVYmvvkbcwDQYJKoZIhvcNAQEL
// SIG // BQAEggIATSRmO0BRdKOYutT8OBfKjFnp6WcvacKJwS82
// SIG // 8UibuG3MHKITygzVsSJk8hYsEV0lA9M/g7C2IIPrTYsG
// SIG // Pssm7hrc1IMRYvJ85z2DN2AZFXWUKM1bi1JjNX2GJk2E
// SIG // bkbKUMkiroaCEl4KEWUtkXjQt1C4/SYxR/OLRwdrqsYE
// SIG // b9T77sc7C3xIXSefN2HMQ3lvV2N6SyX93wlwZ9Um+h4P
// SIG // h81ZB6mNTwPX9tTp/hWAE7BZbdYDk6m+FONqyzWp7bWc
// SIG // 549xlGq0xhUZoiHwaaKryGAKe6CzeahpsJXlhXCguesW
// SIG // OpcjW9lUs7xqZhwnUBh+B6RSfgbQ5d12EbDEtJuCd5YA
// SIG // BRJgn8leKvcC4iuwhLwelKewh2+ofyQLxtyWg7hVBPoc
// SIG // HV2pHKZ8Asw0IB4rpCK1hz4F8j13K7j3AZdPs5a0Qw48
// SIG // egMuVWtadNQkRuUNib6yU8f+4IlLUZxfN43U2zRIrGK6
// SIG // NHrL8C5kcJUECUDSIapKtz515YsT3GCsswU07tNFjyKo
// SIG // czsmndIGZO00cJdu/Wp4UsAiDde6yi8RXlAEvZ0lCI0K
// SIG // jfBm7CIl6rqXdD2Zkca8S5r2hYrTLOldsm1CSVF/M/4L
// SIG // lD8Nqy0I9aa4Pbj0ZmfkdMxOFbAlK0AEhrXOnGu6WfEQ
// SIG // UwEHDC72dmfdprqscsHOKHSrcAo3zlI=
// SIG // End signature block
