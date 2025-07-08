# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PeriodicJobsController, type: :controller do
  render_views

  let!(:admin) { User.find_by(admin: true) ||
    User.create!(login: 'admin',
                 firstname: 'Admin',
                 lastname: 'User',
                 mail: 'admin@example.com',
                 admin: true,
                 password: 'adminpass',
                 password_confirmation: 'adminpass') }
  let!(:periodic_job) { PeriodicJob.create!(title: 'Test',
                                            path: 'xss_test.sh',
                                            periodicity: '* * * * *',
                                            author_id: admin.id) }

  before do
    script_dir = Rails.root.join('script')
    FileUtils.mkdir_p(script_dir)
    File.write(script_dir.join('xss_test.sh'), "<script>alert('xss')</script>\nligne2")
    session[:user_id] = admin.id
  end

  after do
    FileUtils.rm_f(Rails.root.join('script', 'xss_test.sh'))
  end

  it 'escapes script content' do
    get :show, params: { id: periodic_job.id }
    expect(response.body).to include("&lt;script&gt;alert('xss')&lt;/script&gt;")
    expect(response.body).not_to include('<script>alert(')
  end
end
