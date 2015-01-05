class @D3ToolTipsBar
  set: (theme_id)->
    margin =
    top: 40
    right: 20
    bottom: 30
    left: 40

    width = 960 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom
    formatPercent = d3.format(".0%")

    x = d3.scale.ordinal().rangeRoundBands([
      0
      width
    ], .1)

    y = d3.scale.linear().range([
      height
      0
    ])

    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left").tickFormat(formatPercent)

    tip = d3.tip().attr("class", "d3-tip").offset([
      -10
      0
    ]).html((d) ->
      "<strong>Frequency:</strong> <span style='color:red'>" + d.frequency + "</span>"
    )

    svg = d3.select("#point_graph").append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")")
    svg.call tip

    d3.json theme_id + "/point_graph", (error, data) ->
      x.domain data.user_point_graph.map((d) ->
        d.created_at
      )
      y.domain [
        0
        d3.max(data.user_point_graph, (d) ->
          d.sum
        )
      ]
      svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call xAxis
      svg.append("g").attr("class", "y axis").call(yAxis).append("text").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", ".71em").style("text-anchor", "end").text "Frequency"
      svg.selectAll(".bar").data(data.user_point_graph).enter().append("rect").attr("class", "bar").attr("x", (d) ->
        x d.created_at
      ).attr("width", x.rangeBand()).attr("y", (d) ->
        y d.sum
      ).attr("height", (d) ->
        height - y(d.sum)
      ).on("mouseover", tip.show).on "mouseout", tip.hide
      return

  type = (d) ->
    d.sum = +d.sum
    d

@myd3_tooltips_bar = new D3ToolTipsBar()
