# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'cucumber/rails'
require 'cucumber/rspec/doubles'
require 'capybara/poltergeist'
require 'billy/capybara/cucumber'
require 'webmock/cucumber'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
                                    url_blacklist: ["anon-stats.eff.org"],
                                    phantomjs_logger: StringIO.new,
                                    js_errors: true)
end

Capybara.javascript_driver = :poltergeist

WebMock.allow_net_connect!

Billy.configure do |c|
  c.cache = true
  c.cache_request_headers = false
  c.persist_cache = true
  c.cache_path = 'features/req_cache/'
  c.after_cache_handles_request = proc do |_request, response|
    response[:headers]['Access-Control-Allow-Origin'] = "*"
  end
end

# Don't prevent form fills by bots during the test run
InvisibleCaptcha.setup do |config|
  config.timestamp_enabled = false
end

# Capybara defaults to CSS3 selectors rather than XPath.
# If you'd prefer to use XPath, just uncomment this line and adjust any
# selectors in your step definitions to use the XPath syntax.
# Capybara.default_selector = :xpath

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

# You may also want to configure DatabaseCleaner to use different strategies for certain features and scenarios.
# See the DatabaseCleaner documentation for details. Example:
#
#   Before('@no-txn,@selenium,@culerity,@celerity,@javascript') do
#     # { :except => [:widgets] } may not do what you expect here
#     # as Cucumber::Rails::Database.javascript_strategy overrides
#     # this setting.
#     DatabaseCleaner.strategy = :truncation
#   end
#
#   Before('~@no-txn', '~@selenium', '~@culerity', '~@celerity', '~@javascript') do
#     DatabaseCleaner.strategy = :transaction
#   end
#

# Possible values are :truncation and :transaction
# The :transaction strategy is faster, but might give you threading problems.
# See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
Cucumber::Rails::Database.javascript_strategy = :truncation

Before('@billy') do
  Capybara.current_driver = :poltergeist_billy
end

After do
  Capybara.use_default_driver
end

Before do
  stub_civicrm
end

def stub_smarty_streets
  stub_resp = {"city"=>"San Francisco", "state_abbreviation"=>"CA", "state"=>"California", "mailable_city"=>true}
  allow(SmartyStreets).to receive(:get_city_state).with("94109").and_return(stub_resp)
end


def stub_smarty_streets_street_address
  stubbed_address = '[{"input_index":0,"candidate_index":0,"delivery_line_1":"815 Eddy St","last_line":"San Francisco CA 94109-7701","delivery_point_barcode":"941097701156","components":{"primary_number":"815","street_name":"Eddy","street_suffix":"St","city_name":"San Francisco","state_abbreviation":"CA","zipcode":"94109","plus4_code":"7701","delivery_point":"15","delivery_point_check_digit":"6"},"metadata":{"record_type":"S","zip_type":"Standard","county_fips":"06075","county_name":"San Francisco","carrier_route":"C043","congressional_district":"12","rdi":"Commercial","elot_sequence":"0167","elot_sort":"A","latitude":37.78277,"longitude":-122.42104,"precision":"Zip9","time_zone":"Pacific","utc_offset":-8,"dst":true},"analysis":{"dpv_match_code":"Y","dpv_footnotes":"AABB","dpv_cmra":"N","dpv_vacant":"N","active":"Y"}}]'
  allow_any_instance_of(SmartyStreetsController).to receive(:get_data_on_address_zip).and_return(stubbed_address)
end

def stub_legislators
  nancy = CongressMember.create!(
    full_name: "Nancy Pelosi",
    first_name: "Nancy",
    last_name: "Pelosi",
    bioguide_id: "P000197",
    phone: "202-225-4965",
    term_end: (Time.now + 1.year).strftime("%Y-%m-%d"),
    chamber: "senate",
    state: "ca",
    twitter_id: "NancyPelosi"
  )

  allow(CongressMember).to receive(:lookup).and_return([nancy])
end

def wait_until
  require "timeout"
  Timeout.timeout(Capybara.default_max_wait_time) do
    sleep(0.1) until value = yield
    value
  end
end
