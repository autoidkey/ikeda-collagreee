class @C3
  set: (theme_id)->
    url = theme_id + '/point_graph'
    $.get url, (json)->
      chart = c3.generate(
        bindto: "#chart"
        data:
          json:
            json.user_point_graph
          keys:
            value: [
              'sum'
              'created_at'
            ]
          x: 'created_at'
          xFormat: '%Y/%m/%d %H:%M'

        axis:
          x:
            label: '日時'
            position: 'outer-middle'
            type: 'timeseries'
          y:
            label: '合計獲得ポイント数（points）'

      )

  set_ranking: (theme_id) ->
    url = theme_id + '/user_point_ranking'
    $.get url, (json)->
      chart = c3.generate
        bindto: "#ranking-chart"
        data:
          json:
            json.ranking
          keys:
            value: [
              'point'
              'name'
            ]
          x: 'name'
          type: 'bar'

        axis:
          x:
            label: 'ユーザ'
            position: 'outer-middle'
            type: 'category'
          y:
            label: '各ユーザのポイント数'

        # tooltip:
        #   format:
        #     title: json.ranking.name
        tooltip:
          format:
            name: (name, ration, id, index) ->
              name
            value: (value, ration, id, index) ->
              value

@myc3 = new C3()
