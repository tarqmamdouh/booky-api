class SessionsController < ApplicationController
  # GET /sessions/alive
  # check user-session status
  def alive
    status = if current_user.present?
               { status: 200, message: 'Session is alive' }
             else
               { status: 401, message: 'No active users found' }
             end

    # render the status anyway
    render(json: status)
  end
end
