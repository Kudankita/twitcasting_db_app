# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecordMovieJob, type: :job do
  include ActiveJob::TestHelper
  subject(:job) { described_class.perform_later('param_1', 'param_2') }
  xit 'executes perform' do
    # TODO: 最後に消す
    perform_enqueued_jobs(&method(:job))
  end
end
