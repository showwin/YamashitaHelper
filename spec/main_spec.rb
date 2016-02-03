require_relative '../main.rb'

RSpec.describe 'YamashitaHelper' do
  describe '#daily_init' do
    it 'should create today and yesterday string' do
      Clockwork.daily_init(Date.new(2015, 01, 01), true)
      expect(Clockwork.today_year).to eq('27年')
      expect(Clockwork.today_month).to eq('1月')
      expect(Clockwork.today_day).to eq('1日')
      expect(Clockwork.ystday_year).to eq('26年')
      expect(Clockwork.ystday_month).to eq('12月')
      expect(Clockwork.ystday_day).to eq('31日')
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

  # 監視先サイトのHTML構造が変わっている場合 (それでも検知しないといけない)
  describe '#check_site to the other dom' do
    before(:each) do
      Clockwork.today_updated = false
      Clockwork.yesterday_updated = false
      Clockwork.daily_init(Date.new(2016, 1, 15), true)
    end

    # today -> 2016/01/15
    context 'page updated today' do
      it 'should detect update' do
        Clockwork.check_site('./spec/fixtures/the_other_dom.html', true)
        expect(Clockwork.today_updated).to be_truthy
        expect(Clockwork.yesterday_updated).to be_falsey
        expect(Clockwork.scrp.dom_changed?).to be_falsey
      end
    end
  end
end
