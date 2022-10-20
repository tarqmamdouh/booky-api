class BookingsController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_booking, only: :show

  # GET /bookings
  def index
    render json: Booking.free_times(params[:date], params[:interval].to_i)
  end

  # GET /bookings/1
  def show
    render json: format_booking(@booking)
  end

  # POST /bookings
  def create
    success, result = Booking.safe_create(
      booking_params.merge(
        {
          interval: params[:interval],
          date: params[:date]
        }
      )
    )

    if success
      render json: format_booking(result), status: :created, location: @booking
    else
      render json: result, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_booking
    @booking = Booking.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def booking_params
    params.require(:booking).permit(:name, :description, :start, :end, :user_id)
  end

  def format_booking(booking)
    BookingSerializer.new(booking).serializable_hash
  end
end
