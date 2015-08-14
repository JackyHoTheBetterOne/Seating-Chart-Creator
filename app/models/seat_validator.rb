class SeatSelectionValidator
  attr_reader :event_id
  attr_reader :seat_collection
  attr_reader :column_collection
  attr_reader :row_collection
  attr_reader :seat_object
  attr_reader :condition_1
  attr_reader :condition_2

# Cannot select a bunch of seats with one empty seat in between - 1
# Cannot leave a seat at the end of a row or in between seats - 2

  def initialize(options={})
    @seat_collection = options[:seat_collection]
    @event_id = options[:event_id]
    @condition_1 = false
    @condition_2 = false
    @column_collection = []
    @row_collection = []
    @seat_object = {}
    @seat_collection.each do |s|
      @row_collection.push(s.row) if !@row_collection.index(s.row)
      @column_collection.push(s.column.to_i) if !@column_collection.index(s.column)
      @seat_object[s.row] = [] if !@seat_object.has_key?(s.row)
    end

    @seat_collection.each do |s|
      @seat_object[s.row].push(s.column.to_i) if !@seat_object[s.row].index(s.column)
    end

    @column_collection.sort!

    @seat_object.each do |row, columns|
      @seat_object[row] = columns.sort
    end
  end

  def validation
    @seat_object.each do |row, columns|
      i = 0
      count = columns.count
      current_column = 0
      while i < count do
        current_column = columns[i]
        next_column = column[i+1]
        if (current_column+1) != next_column && next_column
          available_seat_num = Seat.find_available_seats_by_column_range(
                                @event_id, row.to_s, current_column, next_column).count
          if (available_seat_num-2) == 1
            return false
          end
        end
        i+=1
      end
    end
    @condition_1 = true

    @seat_object.each do |row, columns|
      first_seat_column = columns.first
      last_seat_column = columns.last

      first_seat_object = Seat.find_available_seats_by_column_range(
                            @event_id, row.to_s, first_seat_column, first_seat_column)
      last_seat_object = Seat.find_available_seats_by_column_range(
                            @event_id. row.to_s, last_seat_column, last_seat_column)

      begining_array = Seat.find_available_seats_by_column_range(
                        @event_id, row.to_s, first_seat_column-2, first_seat_column-1)
      ending_array = Seat.find_available_seats_by_column_range(
                      @event_id, row.to_s, last_seat_column+2, last_seat_column+1)

      if begining_array.count == 1
        return false if (begining_array.first.x_coor - first_seat_object.x_coor).abs < 13
      elsif ending_array.count == 1
        return false if (ending_array.first.x_coor - last_seat_object.x_coor).abs < 13
      elsif begining_array.count == 2
        return false if (begining_array.first.x_coor - begining_array.last.x_coor).abs > 13
      elsif ending_array.count == 2
        return false if (ending_array.first.x_coor - ending_array.last.x_coor).abs > 13
      end
    end
    @condition_2 = true
    return self.result()
  end

  def result
    return @condition_1 && @condition_2
  end

end
