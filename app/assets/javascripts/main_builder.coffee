document.addEventListener 'page:change', (event) ->
  window.BUILDER = {
    chart: S$("seatty-for-real"),
    toggle_object: {
      circle_creation: true,
      circle_deletion: false,
      point_selection: false,
      line_deletion: false,
      text_creation: false,
      text_selection: false
    },
    two_way_points: [],
    events: {
      undoSection: (event) ->
        group = BUILDER.chart.lastSections
        if group.length == 0
          alert('There is no last section to undo')
        else
          BUILDER.chart.deleteLastGroup()
      createSection: (event) ->
        path = document.getElementsByClassName("selected-line")[0]
        if typeof path isnt "undefined"
          column = parseInt(document.getElementById("section-column").value)
          row = parseInt(document.getElementById("section-row").value)
          margin = parseFloat(document.getElementById("row-margin").value)
          row_start_num = document.getElementById('row-start-num').value
          column_start_num = document.getElementById('column-start-num').value
          BUILDER.chart.createSeatSection(path, column, row, 
              margin, column_start_num, row_start_num)
          BUILDER.attach_circle_event({category: 'general'}, BUILDER.events.delete_circle)
        else
          alert('Please select a base row')
      adjust_line: (event) ->
        element = document.getElementsByClassName("selected-line")[0]
        if typeof element is 'undefined'
          alert('Must select a line first')
        else 
          value = parseFloat(event.target.value)
          BUILDER.chart.changePath(element, value)
      select_line: (event) ->
        line = this
        lines = document.getElementsByClassName('base-row-line')
        i = 0
        length = lines.length
        while i < length
          lines[i].setAttribute('class', 'base-row-line')
          i++
        line.setAttribute('class', 'base-row-line selected-line')
      delete_line: (event) ->
        line = this
        if BUILDER.toggle_object.line_deletion
          line.remove()
      draw_line: (event) ->
        arr = BUILDER.two_way_points
        but = this
        if arr.length != 2
          alert('Need two points to create the base row')
        else
          c1 = arr[0]
          c2 = arr[1]
          type = this.getAttribute('data-type')
          BUILDER.chart.createPath(c1, c2, 2, type)
          BUILDER.attach_line_event(BUILDER.events.delete_line)
          BUILDER.attach_line_event(BUILDER.events.select_line)
          c1.remove()
          c2.remove()
          BUILDER.two_way_points = []
      point_selection: (event) ->
        circle = this
        point_arr = BUILDER.two_way_points
        if BUILDER.toggle_object.point_selection
          if point_arr.length == 2 
            index = point_arr.indexOf(circle)
            if index isnt -1
              circle.setAttribute('class', 'point-circle')
              point_arr.splice(index,1)
            else
              alert("Please remove a way point before adding another")
          else if point_arr.length == 1 && point_arr.indexOf(circle) isnt -1
          else
            circle.setAttribute('class', 'point-circle selected-circle')
            point_arr.push(circle)
      text_creation: (event) ->
        map = BUILDER.chart.svg
        if BUILDER.toggle_object.text_creation
          pt = BUILDER.convert_mouse_click_coors(map, event)
          coor_x = pt.x
          coor_y = pt.y
          text = document.getElementById('map-text').value
          BUILDER.chart.createText({
            type: "single",
            txt: text,
            attr: {
              x: coor_x,
              y: coor_y,
              fill: "black",
              'font-size': "11",
              class: 'row-text'
            }
          })
          BUILDER.attach_text_event(BUILDER.events.text_selection)
      text_selection: (event) ->
        text = this
        if BUILDER.toggle_object.text_selection
          if text isnt BUILDER.text_selected
            console.log('what is up')
            texts = document.getElementsByClassName('row-text')
            length = texts.length
            i = 0
            while i<length
              texts[i].setAttribute('fill','black')
              i++
            text.setAttribute('fill', 'red')
            BUILDER.text_selected = text
      text_row_creation: (event) ->
        text = BUILDER.text_selected
        row = parseInt(document.getElementById('section-row').value)
        margin = parseFloat(document.getElementById('row-margin').value)
        path = document.getElementsByClassName("selected-line")[0]
        row_start = document.getElementById('row-start-num').value
        BUILDER.chart.generateTextSection(path, row, margin, row_start)
      point_creation: (event) ->
        map = BUILDER.chart.svg
        if BUILDER.toggle_object.circle_creation  
          radius_input = document.getElementById('single-circle-radius').value
          pt = BUILDER.convert_mouse_click_coors(map, event)
          coor_x = pt.x
          coor_y = pt.y
          BUILDER.chart.createCircle({
            cx: coor_x,
            cy: coor_y,
            r: radius_input || 3,
            class: 'point-circle'
          })
          BUILDER.attach_circle_event({category: 'general'}, BUILDER.events.delete_circle)
          BUILDER.attach_circle_event({category: 'point'}, BUILDER.events.point_selection)
      delete_circle: (event) ->
        circle = this
        if BUILDER.toggle_object.circle_deletion
          arr = BUILDER.two_way_points
          index = arr.indexOf(circle)
          if index isnt -1
            arr.splice(index, 1)
          BUILDER.chart.deleteCircle(circle)
      toggle_functionality: (event) ->
        toggle = this
        toggle_klass = "builder-function-toggle"
        toggle_array = document.getElementsByClassName(toggle_klass)
        king_prop = this.getAttribute("id")
        toggle_obj = BUILDER.toggle_object
        for prop of toggle_obj
          toggle_obj[prop] = false
        i = 0
        length = toggle_array.length
        while i < length
          toggle_array[i].className = toggle_klass
          i++
        toggle_obj[king_prop] = true
        this.className += " toggle-on"
    },
    convert_mouse_click_coors: (svg, click_event) ->
      pt = svg.createSVGPoint()
      pt.x = click_event.clientX
      pt.y = click_event.clientY
      pt = pt.matrixTransform(svg.getScreenCTM().inverse())
      return pt
    attach_toggle_funtionality_event: (func) ->
      toggle_array = document.getElementsByClassName("builder-function-toggle")
      i = 0
      length = toggle_array.length
      while i < length
        toggle_array[i].addEventListener('click', func, false)
        i++
    attach_circle_event: (obj,func) ->
      circle_array = []
      switch obj.category
        when 'general'
          circle_array = document.getElementsByTagName('circle')
        when 'point'
          circle_array = document.getElementsByClassName('point-circle')
        when 'seat' 
          circle_array = document.getElementsByClassName('seat-circle')
      i = 0
      length = circle_array.length
      while i < length
        circle_array[i].addEventListener('click', func, false)
        i++
    attach_map_event: (func) ->
      self = this
      map = self.chart.svg
      map.addEventListener('click', func, false)
    attach_line_event: (func) ->
      line_arr = document.getElementsByClassName('base-row-line')
      i = 0
      length = line_arr.length
      while i < length
        line_arr[i].addEventListener('click', func, false)
        i++
    attach_text_event: (func) ->
      text_arr = document.getElementsByClassName("row-text")
      i = 0
      length = text_arr.length
      while i < length
        text_arr[i].addEventListener('click', func, false)
        i++
  }
  BUILDER.attach_text_event(BUILDER.events.text_creation)
  BUILDER.attach_map_event(BUILDER.events.point_creation)
  BUILDER.attach_map_event(BUILDER.events.text_creation)
  BUILDER.attach_circle_event({category: 'general'}, BUILDER.events.delete_circle)
  BUILDER.attach_toggle_funtionality_event(BUILDER.events.toggle_functionality)
  document.getElementById('draw-line-but').addEventListener(
    'click', BUILDER.events.draw_line, false)
  document.getElementById('draw-vertical-line-but').addEventListener(
    'click', BUILDER.events.draw_line, false)
  document.getElementById('line-curve').addEventListener(
    'change', BUILDER.events.adjust_line, false)
  document.getElementById('create-section').addEventListener(
    'click', BUILDER.events.createSection, false)
  document.getElementById('undo-section').addEventListener(
    'click', BUILDER.events.undoSection, false)
  document.getElementById('text-row-creation').addEventListener(
    'click', BUILDER.events.text_row_creation, false)





