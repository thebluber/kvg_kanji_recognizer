module API
  module Defaults
    def self.included(base)
      base.format :json
      base.default_format :json
      base.prefix :api
    end
  end
end
