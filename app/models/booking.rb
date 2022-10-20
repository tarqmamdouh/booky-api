class Booking < ApplicationRecord
  belongs_to :user

  # Thread-Safe record creation
  # so we make sure bookings are not duplicated and not overlapped
  def self.safe_create(params)
    # we can improve this by adding queueing systems
    $db_thread.synchronize do
      # declare starting/ending dates
      start_at = DateTime.parse(params[:start])
      end_at = DateTime.parse(params[:end])

      # Return error if this slot overlapped with recently booked slots
      return [false, ['The selected slot is overlapping with a booked slot, please try again']] if slot_overlaps?(params[:date], start_at, end_at)

      booking = new(
        {
          name: params[:name],
          description: params[:description],
          start: start_at,
          end: end_at,
          user_id: params[:user_id].to_i
        }
      )

      return [true, booking] if booking.save

      # return an error
      return [false, booking.errors]
    end
  end

  # Get free and non reserved/booked times for a specific day
  def self.free_times(date, interval = 15)
    # collect all reserved times given
    reserved_times = reservations(date)

    # return all slots as no reservations in this day
    return slots_between(
      DateTime.parse("#{date} 12:00:00AM"),
      DateTime.parse("#{date} 11:59:59PM"),
      interval
    ) if reserved_times.empty?

    # each reserved slot contains the following [start_at, end_at]
    # loop through sorted reserved slots and do the following:
    #   - for the first item find all intervels between 12:00:00AM and start_at
    #   - for all items find all intervels between end_at and next start_at
    #   - for the last item find all intervels between end_at and 11:59:59PM
    slots = []
    reserved_times.each_with_index do |reservation, index|
      rstart, _rend = reservation
      slots += if index.zero?
                 slots_between(
                   DateTime.parse("#{date} 12:00:00AM"),
                   reserved_times[0][0].to_datetime,
                   interval
                 )
               else
                 slots_between(
                   reserved_times[index - 1][1].to_datetime,
                   rstart.to_datetime,
                   interval
                 )
               end
    end

    # merge last interval also
    slots += slots_between(
      reserved_times[-1][1].to_datetime,
      DateTime.parse("#{date} 11:59:59PM"),
      interval
    )
  end

  # Remove reservations for specific date
  def self.delete_reserved(date)
    day_start_at = date.to_date + Time.parse('12:00AM').seconds_since_midnight.seconds
    day_end_at = date.to_date + Time.parse('11:59:59PM').seconds_since_midnight.seconds
    where('start > ? AND end < ?', day_start_at, day_end_at).delete_all
  end

  # day starts at 12:00:00 AM and ends At 11:59:59 PM
  # get all -confirmed- reservations from the database
  # date: (string) a YYYY-MM-DD formatted date to look at
  def self.reservations(date)
    day_start_at = date.to_date + Time.parse('12:00AM').seconds_since_midnight.seconds
    day_end_at = date.to_date + Time.parse('11:59:59PM').seconds_since_midnight.seconds
    where('start >= ? AND end <= ?', day_start_at, day_end_at).sort_by(&:start).pluck(:start, :end)
  end

  # Find all available slots given
  # start: (datetime) starting time
  # end: (datetime) ending time
  # interval: (Int) intervals to divide the time to them
  def self.slots_between(starting_at, ending_at, interval)
    # calculate how many slots available
    intervals_num = ((starting_at - ending_at).abs * 24 * 60).to_i / interval
    return [] if intervals_num.zero?

    # loop using numbers and generate slots
    (1..intervals_num).each_with_object([]) do |n, slots|
      slot_start_at = starting_at + (n * interval).minutes - interval.minutes
      slot_ending_at = starting_at + (n * interval).minutes

      slots << [slot_start_at, slot_ending_at] if slot_ending_at <= ending_at
    end
  end

  # check if the slot overlap with any reserved slots
  def self.slot_overlaps?(date, start_at, end_at)
    reserved_times = reservations(date)

    overlaps = reserved_times.select do |reserved_time|
      (start_at.to_datetime < reserved_time[1].to_datetime) &&
        (reserved_time[0].to_datetime < end_at.to_datetime)
    end

    !overlaps.empty?
  end
end
