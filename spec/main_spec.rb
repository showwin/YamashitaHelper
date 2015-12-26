require_relative '../script.rb'

RSpec.describe 'YamashitaHelper' do
  describe '#daily_init' do
    it 'should create today and yesterday string' do
      Clockwork.daily_init(Date.new(2015, 01, 01), true)
      expect(Clockwork.today_str).to eq('27年1月1日')
      expect(Clockwork.ystday_str).to eq('26年12月31日')
    end

    it 'should init today_updated' do
      Clockwork.daily_init(nil, true)
      expect(Clockwork.today_updated).to be_falsey

      Clockwork.today_updated = true
      Clockwork.daily_init(nil, true)
      expect(Clockwork.today_updated).to be_falsey
    end

    it 'should init yesterday_updated' do
      Clockwork.daily_init(nil, true)
      expect(Clockwork.yesterday_updated).to be_falsey

      Clockwork.today_updated = true
      Clockwork.daily_init(nil, true)
      expect(Clockwork.yesterday_updated).to be_truthy
    end
  end

  describe '#check_site' do
    before(:each) do
      Clockwork.today_updated = false
      Clockwork.yesterday_updated = false
      Clockwork.daily_init(Date.new(2015, 12, 10), true)
    end

    # today -> 2015/12/10
    context 'page updated today' do
      it 'should detect update' do
        Clockwork.check_site('./spec/fixtures/today.html', true)
        expect(Clockwork.today_updated).to be_truthy
        expect(Clockwork.yesterday_updated).to be_falsey
        expect(Clockwork.scrp.dom_changed?).to be_falsey
      end
    end

    # yesterday -> 2015/12/09
    context 'page updated yesterday' do
      it 'should detect update' do
        Clockwork.check_site('./spec/fixtures/yesterday.html', true)
        expect(Clockwork.today_updated).to be_falsey
        expect(Clockwork.yesterday_updated).to be_truthy
      end
    end

    # 2 days before -> 2015/12/08
    context 'page updated 2 days before' do
      it 'should not detect update' do
        Clockwork.check_site('./spec/fixtures/2d-before.html', true)
        expect(Clockwork.today_updated).to be_falsey
        expect(Clockwork.yesterday_updated).to be_falsey
      end
    end

    context 'page has wrong DOM' do
      it 'should not detect update' do
        Clockwork.check_site('./spec/fixtures/dom_changed.html', true)
        expect(Clockwork.today_updated).to be_falsey
        expect(Clockwork.yesterday_updated).to be_falsey
      end

      it 'should report DOM error' do
        Clockwork.check_site('./spec/fixtures/dom_changed.html', true)
        expect(Clockwork.today_updated).to be_falsey
        expect(Clockwork.yesterday_updated).to be_falsey
        expect(Clockwork.scrp.dom_changed?).to be_truthy
      end
    end
  end
end
