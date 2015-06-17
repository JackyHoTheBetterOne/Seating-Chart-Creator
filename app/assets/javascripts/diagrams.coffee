# # Place all the behaviors and hooks related to the matching controller here.
# # All this logic will automatically be available in application.js.
# # You can use CoffeeScript in this file: http://coffeescript.org/

window.solveUrl = (obj) ->  
  Object.keys(obj).map((k) ->
    item = obj[k]
    if item.constructor.name isnt "Array"
      encodeURIComponent(k) + '=' + encodeURIComponent(item)
    else 
      key = encodeURIComponent(k) + "%5B%5D="
      array_url = []
      i = 0 
      count = item.length
      while i < count 
        array_url.push(key + encodeURIComponent(item[i]))
        i++
      return array_url.join("&")
  ).join '&'

window.ajax_insane_style = (obj) ->
  checkFunction = (callback, args) ->
    callback(args) if typeof callback isnt "undefined"
  checkFunction(obj["before_send"])
  request = new XMLHttpRequest()
  url = obj["url"] 
  params = undefined
  true_url = undefined
  if typeof obj["url_params"] isnt "undefined"
    params = obj["url_params"] 
  else if typeof obj["form_data_params"] isnt "undefined"
    params = obj["form_data_params"]
  else 
    params = ""
  request.onreadystatechange = ->
    if request.readyState is XMLHttpRequest.DONE
      checkFunction(obj["complete_call"])
      status = request.status
      if status is 200
        checkFunction(obj["success_call"], request.responseText)
      else if status is 400
        checkFunction(obj["error_call"])
      else 
        checkFunction(obj["epic_fail_call"])
  method = obj["method"].toUpperCase()
  if method is "POST"
    request.open("POST", url, true)
    # request.setRequestHeader("Content-type", "application/x-www-form-urlencoded")  
    request.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr('content'))
    # request.setRequestHeader("Content-length", params.length)
    # request.setRequestHeader("Connection", "close")
    request.send(params)
  else if method is "GET"
    true_url = if params.length > 0 then url + "?" + params else url
    request.open("GET", true_url, true)
    request.send()

# $ ->
#   createCircle = (x,y,r) ->
#     circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle')
#     circle.setAttribute('cx', x)
#     circle.setAttribute('cy', y)
#     circle.setAttribute('r', r)
#     circle.setAttribute('fill', "#3b77bf")
#     circle.setAttribute('stroke', 'none')
#     circle.setAttribute('style', '-webkit-tap-highlight-color: rgba(0, 0, 0, 0); cursor: move;')
#     circle.setAttribute('stroke-width', '1.1096605744125327')
#     return circle
#     # return '<circle ' + 'cx= "' + x + '" cy = "' + y + '" ' + 'r="' + r + '" fill="#3b77bf" stroke="none" style="-webkit-tap-highlight-color: rgba(0, 0, 0, 0); cursor: move;" stroke-width="1.1096605744125327"></circle>'
#   window.createPath = (p1, p2) ->
#     x1 = p1.getAttribute('cx')
#     y1 = p1.getAttribute('cy')
#     x2 = p2.getAttribute('cx')
#     y2 = p2.getAttribute('cy')
#     return '<path d="M' + x1 + ',' + y1 + ' C' + x1 + ',' + (y1-3) + ' ' + x2 + ',' + (y2-3) + ' ' + x2 + ',' + y2 + '" class="stroky" />'
#   window.createSeatPath = (path, svg, column, row, margin) ->
#     length = path.getTotalLength()
#     ball_width = length/column
#     radius = ball_width/2
#     row_reached = 0
#     row_coverage = 0
#     # group = document.createElementNS('http://www.w3.org/2000/svg', 'g')
#     group = document.createDocumentFragment()
#     while row_reached < row 
#       column_coverage = 0
#       while column_coverage < length
#         obj = path.getPointAtLength(column_coverage)
#         circle = createCircle(obj.x+5, obj.y+row_coverage, radius)
#         group.appendChild(circle)
#         column_coverage += ball_width
#       row_coverage += (radius+margin)
#       row_reached++
#     svg.appendChild(group)

#   window.renderCanvas = ->
#     worker = new XMLSerializer()
#     svg_stuff = worker.serializeToString(document.getElementById("seatty-for-real-for-sure"))
#     canvg(document.getElementById('canvas-baby'), svg_stuff,{ ignoreMouse: true, ignoreAnimation: true })
#     attach_canvas_event()
#   create_text = (object) ->
#     x = object["x"]
#     y = object["y"]
#     coors = 'x= "' + object["x"] + '" y= "' + object["y"] + '"'
#     console.log(object)
#     text_html = '<text '+ coors + ' text-anchor="middle" font="10px &quot;Arial&quot;" stroke="#ffffff" fill="#ffffff" style="-webkit-tap-highlight-color: rgba(0, 0, 0, 0); text-anchor: middle; font-style: normal; font-variant: normal; font-weight: normal; font-stretch: normal; font-size: 9px; line-height: normal; font-family: Arial; cursor: move;" font-size="9px" font-weight="normal" stroke-width="1.1096605744125327"><tspan dy="3" style="-webkit-tap-highlight-color: rgba(0, 0, 0, 0);">' + object["text"] + '</tspan></text>'
#     return text_html
#   attach_circle_event = ->
#     elements = document.getElementsByTagName("circle")
#     i = 0
#     length = elements.length
#     while i < length
#       elements[i].addEventListener 'click', ->
#         object = {}
#         object["x"] = $(this).attr("cx")
#         object["y"] = $(this).attr("cy")
#         object["text"] = "Z"
#         element = create_text(object)
#         document.getElementsByTagName("svg")[0].innerHTML += element
#         attach_circle_event()
#       i++
#   attach_svg_event = ->
#     svg = ->
#       return document.getElementById("seatty-for-real-for-sure")
#     map = svg()
#     map.addEventListener 'click', (event) ->
#       pt = map.createSVGPoint()
#       pt.x = event.pageX
#       pt.y = event.pageY
#       pt = pt.matrixTransform(map.getScreenCTM().inverse())
#       coor_x = pt.x
#       coor_y = pt.y
#       map.appendChild(createCircle(coor_x, coor_y, 9))

#   attach_create_diagram_event = ->
#     element = document.getElementById("diagram-saving")
#     element.addEventListener 'click', ->
#       name = document.getElementById("diagram-name").value
#       makeup = document.getElementById("seatty-for-real-for-sure").outerHTML
#       form_object = new FormData()
#       form_object.append("name", name)
#       form_object.append("makeup", makeup)
#       ajax_object = {
#         url: window.location.origin + "/diagrams/going_down_for_real",
#         form_data_params: form_object,
#         method: "POST",
#         success_call: (response) ->
#           console.log(response)
#       }
#       ajax_insane_style(ajax_object)
#   attach_canvas_event  = ->
#     canvas = document.getElementById("canvas-baby")
#     canvas.addEventListener 'click', (event) ->
#       console.log(event)
#   # attach_circle_event()
#   attach_create_diagram_event()
#   attach_svg_event()



#   # $(document).off "click.mad-house", ".mad-house-seating circle"
#   # $(document).on "click.mad-house", ".mad-house-seating circle", ->
#   #   object = {}
#   #   object["x"] = $(this).attr("cx")
#   #   object["y"] = $(this).attr("cy")
#   #   object["text"] = "D"
#   #   element = create_text(object)
#   #   document.getElementsByTagName("svg")[0].innerHTML += element
#   # $()


