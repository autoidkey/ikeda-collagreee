class D3SortableBar
  set: (theme_id)->
    margin =
    top: 40
    right: 20
    bottom: 30
    left: 50

    width = 960 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom
    formatPercent = d3.format(".0%")
    parseDate = d3.time.format("%Y/%m/%d %H:%M").parse

    # スケールと出力レンジの定義
    x = d3.scale.ordinal().rangeRoundBands([
      0
      width
    ], .1, 1)

    y = d3.scale.linear().range([
      height
      0
    ])

    # 軸の定義
    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left")#.tickFormat(formatPercent)

    # tooltipの定義
    tip = d3.tip().attr("class", "d3-tip").offset([
      -10
      0
    ]).html((d) ->
      "<strong>" + d.name + ":</strong> <span style='color:red'>" + d.point + " points</span>"
    )

    # svgの定義
    svg = d3.select("#point_graph").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

    svg.call tip

    # jsonでのデータ読み込み
    d3.json theme_id + "/user_point_ranking", (error, data) ->
      data.ranking.forEach (d) ->
        d.point = +d.point
      # データを入力ドメインとして設定
      x.domain data.ranking.map((d) ->
        d.rank
      )
      y.domain [
        0
        d3.max(data.ranking, (d) ->
          d.point
        )
      ]

      # x軸をsvgに表示
      svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call xAxis

      # y軸をsvgに表示
      svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text "各ユーザの獲得ポイント(points)"

      # 棒グラフを表示
      svg.selectAll(".bar").data(data.ranking).enter().append("rect").attr("class", "bar").attr("x", (d) ->
        x d.rank
      ).attr("width", x.rangeBand()).attr("y", (d) ->
        y d.point
      ).attr("height", (d) ->
        height - y(d.point)
      ).on("mouseover", tip.show).on "mouseout", tip.hide

      d3.select("input#sort-graph").on 'click', change
      sortTimeout = setTimeout(->
        d3.select("input#sort-graph").property("checked", true).each change
      , 2000)

      change = ->
        clearTimeout sortTimeout

        # Copy-on-write since tweens are evaluated after a delay.
        x0 = x.domain(data.ranking.sort((if @checked then (a, b) ->
          b.point - a.point
         else (a, b) ->
          d3.ascending a.rank, b.rank
        )).map((d) ->
          d.rank
        )).copy()
        transition = svg.transition().duration(750)
        delay = (d, i) ->
          i * 50

        transition.selectAll(".bar").delay(delay).attr "x", (d) ->
          x0 d.rank

        transition.select(".x.axis").call(xAxis).selectAll("g").delay delay

  type = (d) ->
    d.sum = +d.sum
    d

@myd3_sortable_bar = new D3SortableBar
