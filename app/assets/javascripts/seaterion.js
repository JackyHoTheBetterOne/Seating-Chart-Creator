(function (global, $) {

  var Seaterion = function (chart) {
    return new Seaterion.init(chart);
  };

  Seaterion.version = "1.0";

  var svg_site = 'http://www.w3.org/2000/svg';

  Seaterion.prototype = {
    createText: function (object) {
      var 
        self = this,
        text = document.createElementNS(svg_site, 'text'),
        attr = object["attr"];

      text.innerHTML = object.txt;
      attr['x'] = attr['x'] - 2;
      for (var prop in attr) {
        text.setAttribute(prop, attr[prop]);
      }

      if(object.type === "single") {
        self.svg.appendChild(text);
        return self;
      } else {
        return text;
      }
    },

    generateTextRow: function(text, row, margin) {
      var 
        self = this,
        txt = text.innerHTML,
        x = parseFloat(text.getAttribute('x')),
        y = parseFloat(text.getAttribute('y')),
        group = document.createElementNS(svg_site, "g");
      for(var i=0; i<row; i++) {
        var 
          addition = margin*(i+1),
          text_element = self.createText({
            type: "group",
            txt: txt,
            attr: {
              x: x,
              y: (y+addition),
              fill: 'black',
              'font-size': '11',
              class: 'row-text'
            }
          });
        group.appendChild(text_element);
      }
      self.lastSections.push(group);
      self.svg.appendChild(group);
      return self;
    },

    generateTextSection: function(path, row, margin, row_start) {
      var 
        self = this,
        group = document.createElementNS(svg_site, 'g'),
        row_array = self.check_and_return_row_array(row_start, row),
        row_array = row_array.reverse();

      for(var row_reached = 0; row_reached < row; row_reached++) {
        var 
          length = row_reached*(margin+5),
          obj = path.getPointAtLength(length),
          text_element = self.createText({
            type: "group",
            txt: row_array[row_reached],
            attr: {
              x: (obj.x-2),
              y: obj.y,
              fill: 'black',
              'font-size': '11',
              class: 'row-text'
            }
          });
        group.appendChild(text_element);
      }
      self.lastSections.push(group);
      self.svg.appendChild(group); 
      return self; 
    },

    createCircle: function (object) {
      var 
        self = this,
        circle = document.createElementNS(svg_site, 'circle');
      object["style"] = object["style"] || '-webkit-tap-highlight-color: rgba(0, 0, 0, 0);';
      object["stroke-width"] = object["stroke-width"] || '1.1096605744125327';
      object["stroke"] = object["stroke"] || 'none';
      object["fill"] = object["fill"] || "#3b77bf";
      object["group"] = object["group"] || false; 

      for (var prop in object) {
        if (prop !== 'group') {
          circle.setAttribute(prop, object[prop]);
        }
      }

      if (!object.group) {
        self.svg.appendChild(circle);
        return self;
      } else {
        return circle;
      }
    },

    deleteCircle: function (circle) {
      var self = this;
      if (circle.className.baseVal.indexOf('seat-circle') !== -1) {
        var 
          deleted_num = parseInt(circle.getAttribute('data-column')),
          circle_row = circle.getAttribute('data-row'),
          row_class_name = "row-" + circle_row,
          group_collection = self.lastSections,
          group_collection_length = group_collection.length,
          column_collection = [];


        for(var i = 0; i < group_collection_length; i++) {
          if (group_collection[i].hasChildNodes(circle)) {
            column_collection = group_collection[i].childNodes;
            break;
          }
        }
        for(var i=0; i < column_collection.length; i++) {
          var
            peer_circle = column_collection[i],
            peer_column = parseInt(peer_circle.getAttribute('data-column')),
            peer_row = peer_circle.getAttribute('data-row')
          if(peer_column > deleted_num && circle_row === peer_row) {
            var 
              new_peer_column = peer_column - 1,
              className = peer_circle.className.baseVal,
              new_column_class = 'column-' + new_peer_column,
              old_column_class = 'column-' + peer_column;
            peer_circle.setAttribute('data-column', new_peer_column);  
            peer_circle.setAttribute('class', className.replace(old_column_class, new_column_class));
          }
        }
      }
      circle.remove();
      return self;
    },

    deleteLastGroup: function () {
      var 
        self = this,
        sections = self.lastSections,
        length = sections.length,
        last_index = length - 1,
        group = self.lastSections[last_index];

      if (group) {
        group.remove();
        sections.pop();
      } else {
        throw 'There is no section in the memory!';
      }

      return self;
    },

    createPath: function (c1, c2, curve, type) {
      var 
        self = this,
        path = document.createElementNS(svg_site, 'path'),
        cA, cB, x1, y1, x2, y2, drawing;
      if (type === 'vertical') {
        cA = (parseFloat(c1.getAttribute('cy')) >= parseFloat(c2.getAttribute('cy'))) ? c2 : c1;
      } else if (type === 'horizontal') {
        cA = (parseFloat(c1.getAttribute('cx')) >= parseFloat(c2.getAttribute('cx'))) ? c2 : c1;
      }
      cB = (cA === c1) ? c2 : c1;
      x1 = cA.getAttribute('cx');
      y1 = cA.getAttribute('cy');
      x2 = cB.getAttribute('cx');
      y2 = cB.getAttribute('cy');
      drawing = 'M' + x1 + ',' + y1 + ' C' + x1 + ',' + (y1-curve) + ' ' + x2 + ',' + (y2-curve) + ' ' + x2 + ',' + y2;
      path.setAttribute('d', drawing);
      path.setAttribute('style', 'stroke-width: 5; stroke: #000; stroke-linecap: round; fill: none;');
      path.setAttribute('class', 'base-row-line')
      path.setAttribute('data-x1', x1)
      path.setAttribute('data-y1', y1)
      path.setAttribute('data-x2', x2)
      path.setAttribute('data-y2', y2)

      self.svg.appendChild(path);
      return self;
    },

    changePath: function (path, curve) {
      var 
        self = this,
        x1 = path.getAttribute('data-x1'),
        y1 = path.getAttribute('data-y1'),
        x2 = path.getAttribute('data-x2'),
        y2 = path.getAttribute('data-y2'),
        drawing = 'M' + x1 + ',' + y1 + ' C' + x1 + ',' + (y1-curve) + ' ' + x2 + ',' + (y2-curve) + ' ' + x2 + ',' + y2;

      path.setAttribute('d', drawing);
      return self;
    },

    get_char_array: function(start, num_needed) {
      for(var result = [], idx=start.charCodeAt(0);
        result.length < num_needed;
        idx ++) {
        result.push(String.fromCharCode(idx));
      };
      return result;
    },

    get_num_array: function(start, num_needed) {
      for(var result = [], num = start; result.length < num_needed; num++) {
        result.push(num)
      };
      return result;
    },

    check_and_return_row_array: function(row_start, row) {
      var 
        self = this,
        row_num = parseInt(row_start);
      return (row_num > 0) ? self.get_num_array(row_num, row):self.get_char_array(row_start, row);
    },

    createSeatSection: function(path, column, row, margin, column_start, row_start) {
      var 
        self = this,
        length = path.getTotalLength(),
        ball_width = length/column,
        radius = ball_width/2,
        row_reached = 0,
        row_coverage = 0,
        group = document.createElementNS('http://www.w3.org/2000/svg', 'g'),
      // var group = document.createDocumentFragment();
        column_array = self.get_num_array(parseInt(column_start), column),
        row_array = self.check_and_return_row_array(row_start, row);
      row_array = row_array.reverse();
      column_array = column_array.reverse();
      for(var row_index = 0;row_reached < row;row_reached++){
        for(var column_coverage = 0, column_index = 0, column_num = 0; column_num < column; column_num+=1) {
          var 
            obj = path.getPointAtLength(column_coverage+0.52*(1+column_num)),
            row_num = row_array[row_index],
            column_num_tbi = column_array[column_index],
            circle = self.createCircle({
              cx: obj.x,
              cy: obj.y+row_coverage,
              r: radius,
              group: true,
              class: 'seat-circle ' + 'row-' + row_num + ' column-' + column_num_tbi,
              'data-row': row_num,
              'data-column': column_num_tbi
            });
          column_index += 1;
          group.appendChild(circle);
          column_coverage += ball_width;
        }
        row_index += 1;
        row_coverage += (radius+margin);
      }
      self.lastSections.push(group);
      self.svg.appendChild(group);
      return self;
    },

    getSeatObject: function() {
      var 
        circle_array = document.getElementsByTagName('circle'),
        row_array = [],
        seat_obj = {};
      
      for(var i = 0; i<circle_array.length; i++) {
        var row = circle_array[i].getAttribute('data-row');
        if(row_array.indexOf(row) === -1) {
          row_array.push(row); 
        } 
      }

      for(var row_index = 0; row_index<row_array.length; row_index++) {
        var 
          row = row_array[row_index],
          column_array = document.getElementsByClassName('row-' + row),
          column_num_array = [];
        for(var column_index = 0; column_index<column_array.length; column_index++) {
          var 
            element = column_array[column_index],
            num = element.getAttribute('data-column');
          column_num_array.push(num);
        }

        seat_obj[row] = column_num_array;
      }
      
      return seat_obj;
    }
  };

  Seaterion.init = function (svg_id) {
    var self = this;
    if (!svg_id) {
      throw "An id pointing to a SVG HTML element is required";
    };
    self.svg = document.getElementById(svg_id);
    self.svg_id = svg_id;
    self.lastSections = [];
    console.log(document.getElementById(svg_id));
  }

  Seaterion.init.prototype = Seaterion.prototype;

  if (typeof global.Seaterion === 'undefined') {
    global.Seaterion = global.S$ = Seaterion;
  }

})(window, jQuery);



