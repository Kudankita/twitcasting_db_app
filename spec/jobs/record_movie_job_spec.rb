# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecordMovieJob, type: :job do
  include ActiveJob::TestHelper
  subject(:job) { described_class.perform_later('params_1', 'param_2.mp4') }
  xit 'executes perform' do
    # TODO: 最後に消す
    perform_enqueued_jobs(&method(:job))
  end

  xit 'test' do
    expect(RecordMovieJob.perform_later('1', '2')).to eq('ok')

  end
end
