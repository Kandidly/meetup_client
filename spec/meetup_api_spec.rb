require 'spec_helper'


describe MeetupApi do
  subject { MeetupApi.new }
  describe "#query_string" do
    it "returns a valid query string" do
      params = { category: '1',
                 status: 'upcoming',
                 time: '0,1m' }
      expect(subject.send(:query_string, params)).to eq 'category=1&status=upcoming&time=0%2C1m'
    end
  end

  context "requests" do
    before do
      allow_any_instance_of(ApiCallers::HttpRequester).to receive(:execute_request).and_return({})
      allow(MeetupClient).to receive_message_chain(:config, :api_key) {'abc'}
    end

    describe "method request" do
      it "named request" do
        expect(ApiCallers::JsonRequest).to receive(:new).with('https://api.meetup.com/2/events?category=1&key=abc', :get, nil, false)
        subject.events({ category: 1 })
      end
    end

    describe "direct request" do
      it "get request" do
        expect(ApiCallers::JsonRequest).to receive(:new).with('https://api.meetup.com/events?category=1&key=abc', :get, nil, false)
        subject.get('/events', { category: 1 })
      end

      it "post request" do
        expect(ApiCallers::JsonRequest).to receive(:new).with('https://api.meetup.com/events?category=1&key=abc', :post, nil, false)
        subject.post('/events', { category: 1 })
      end
    end

    describe "multipart post request" do
      it "request" do
        expect(ApiCallers::JsonRequest).to receive(:new).with('https://api.meetup.com/events?category=1&key=abc', :post, {'file' => ['filename', 'format']}, false)
        subject.multipart_post('/events', {'file' => ['filename', 'format']}, { category: 1 })
      end
    end
  end
end
