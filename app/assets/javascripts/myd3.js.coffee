class @D3
  set: (theme_id)->
    margin =
    top: 20
    right: 20
    bottom: 30
    left: 50

    width = 960 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom
    # parseDate = d3.time.format("%d-%b-%y").parse
    parseDate = d3.time.format("%Y/%m/%d %H:%M").parse

    x = d3.time.scale().range([
      0
      width
    ])

    y = d3.scale.linear().range([
      height
      0
    ])

    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left")

    line = d3.svg.line().x((d) ->
      x d.created_at
    ).y((d) ->
      y d.sum
    )

    # line = d3.svg.line().x((d) ->
    #   x d.date
    # ).y((d) ->
    #   y d.close
    # )

    svg = d3.select("#point_graph").append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")")

    # d3.tsv "/data.tsv", (error, data) ->
    #   data.forEach (d) ->
    #     d.date = parseDate(d.date)
    #     d.close = +d.close
    #     return

    d3.json theme_id + "/point_graph", (error, data) ->
      data.user_point_graph.forEach (d) ->
        d.created_at = parseDate(d.created_at)
        d.sum = +d.sum
        return

      x.domain d3.extent(data.user_point_graph, (d) ->
        d.created_at
      )

      y.domain d3.extent(data.user_point_graph, (d) ->
        d.sum
      )

      svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call xAxis
      svg.append("g").attr("class", "y axis").call(yAxis).append("text").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", ".71em").style("text-anchor", "end").text "Point(ポイント)"
      svg.append("path").datum(data.user_point_graph).attr("class", "line").attr "d", line
      return

@myd3 = new D3()
