require 'rails_helper'

RSpec.describe Booking, type: :model do
  let(:booking) { create :booking }
  let(:user) { create :user }

  it 'returns all slots of the day when no reservations' do
    expect(Booking.free_times('15-10-2022', 15).length).to eq(95)
  end

  it 'returns all non-overlapping free slots' do
    create :booking, name: 'first', description: 'first', start: DateTime.parse('01-02-2022 10:00PM'), end: DateTime.parse('01-02-2022 10:30PM'), user_id: user.id

    free_slots = Booking.free_times('01-02-2022')
    expect(free_slots.include?([DateTime.parse('01-02-2022 10:00PM'), DateTime.parse('01-02-2022 10:30PM')])).to eq(false)
  end

  it 'returns all reservations for specific date' do
    create :booking, name: 'first', description: 'first', start: DateTime.parse('01-02-2022 10:00PM'), end: DateTime.parse('01-02-2022 10:30PM'), user_id: user.id

    reservations = Booking.reservations('01-02-2022')
    expect(reservations.length).to eq 1
  end

  it 'removes reservation for specific date' do
    create :booking, name: 'first', description: 'first', start: DateTime.parse('01-02-2022 10:00PM'), end: DateTime.parse('01-02-2022 10:30PM'), user_id: user.id

    Booking.delete_reserved('01-02-2022')
    expect(Booking.reservations('01-02-2022').empty?).to eq true
  end

  it 'gets exactly 2 free slots for 60 mins interval and 1 hour freetime' do
    create :booking, name: 'first', description: 'first', start: DateTime.parse('01-02-2022 12:00AM'), end: DateTime.parse('01-02-2022 6:00PM'), user_id: user.id
    create :booking, name: 'second', description: 'second', start: DateTime.parse('01-02-2022 7:00PM'), end: DateTime.parse('01-02-2022 11:15PM'), user_id: user.id

    free_slots = Booking.free_times('01-02-2022', 60)
    expect(free_slots.length).to eq 1
  end

  it 'gets empty slots for full reserved day' do
    create :booking, name: 'first', description: 'first', start: DateTime.parse('01-02-2022 12:00AM'), end: DateTime.parse('01-02-2022 11:59PM'), user_id: user.id

    free_slots = Booking.free_times('01-02-2022', 60)
    expect(free_slots.length).to eq 0
  end

  it 'validates that interval does not overlap with a reserved booking' do
    create :booking, name: 'first', description: 'first', start: DateTime.parse('01-02-2022 3:00AM'), end: DateTime.parse('01-02-2022 11:59PM'), user_id: user.id
    create :booking, name: 'second', description: 'second', start: DateTime.parse('01-02-2022 2:00AM'), end: DateTime.parse('01-02-2022 11:15PM'), user_id: user.id
    success, result = Booking.safe_create({
      name: 'second',
      description: 'second',
      start: '01-02-2022 2:00AM',
      end: '01-02-2022 4:00AM',
      user_id: user.id,
      date: '01-02-2022',
      interval: 120
    })

    expect(success).to eq false
    expect(result.any? { |s| s.include?('overlapping') }).to eq true
  end

  describe '(validations)' do
    subject { booking }

    it { should validate_presence_of(:start) }
    it { should validate_presence_of(:end) }
    it { should validate_uniqueness_of(:start).scoped_to(:end) }
  end
end
