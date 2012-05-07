require 'rbench'

def action_view
  require 'action_view'
end

def active_support_core_ext_array_grouping
  require 'active_support/core_ext/array/grouping'
end

def active_support_core_ext_date_calculations
  require 'active_support/core_ext/date/calculations'
end

def active_support_core_ext_integer_time
  require 'active_support/core_ext/integer/time'
end

def active_support_core_ext_numeric_time
  require 'active_support/core_ext/numeric/time'
end

def csv
  require 'csv'
end

def fastercsv
  require 'fastercsv'
end

def geokit
  require 'geokit'
end

def htmlentities
  require 'htmlentities'
end

def json
  require 'json'
end

def launchy
  require 'launchy'
end

def oauth
  require 'oauth'
end

def open_uri
  require 'open-uri'
end

def retryable
  require 'retryable'
end

def thor
  require 'thor'
end

def tweetstream
  require 'tweetstream'
end

def time
  require 'time'
end

def twitter
  require 'twitter'
end

def twitter_text
  require 'twitter-text'
end

def yaml
  require 'yaml'
end

RBench.run(1) do
  column :one, :title => 'first require'
  column :two, :title => 'second require'

  report "action_view" do
    one{action_view}
    two{action_view}
  end

  report "active_support/core_ext/array/grouping" do
    one{active_support_core_ext_array_grouping}
    two{active_support_core_ext_array_grouping}
  end

  report "active_support/core_ext/date/calculations" do
    one{active_support_core_ext_date_calculations}
    two{active_support_core_ext_date_calculations}
  end

  report "active_support/core_ext/integer/time" do
    one{active_support_core_ext_integer_time}
    two{active_support_core_ext_integer_time}
  end

  report "active_support/core_ext/numeric/time" do
    one{active_support_core_ext_numeric_time}
    two{active_support_core_ext_numeric_time}
  end

  report "csv" do
    one{csv}
    two{csv}
  end

  report "fastercsv" do
    one{fastercsv}
    two{fastercsv}
  end

  report "geokit" do
    one{geokit}
    two{geokit}
  end

  report "htmlentities" do
    one{htmlentities}
    two{htmlentities}
  end

  report "json" do
    one{json}
    two{json}
  end

  report "launchy" do
    one{launchy}
    two{launchy}
  end

  report "oauth" do
    one{oauth}
    two{oauth}
  end

  report "open-uri" do
    one{open_uri}
    two{open_uri}
  end

  report "retryable" do
    one{retryable}
    two{retryable}
  end

  report "thor" do
    one{thor}
    two{thor}
  end

  report "tweetstream" do
    one{tweetstream}
    two{tweetstream}
  end

  report "time" do
    one{time}
    two{time}
  end

  report "twitter" do
    one{twitter}
    two{twitter}
  end

  report "twitter-text" do
    one{twitter_text}
    two{twitter_text}
  end

  report "yaml" do
    one{yaml}
    two{yaml}
  end

end
