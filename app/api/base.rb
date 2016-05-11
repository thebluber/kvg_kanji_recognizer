module API
  class Base < Grape::API
    mount API::Version1
  end
end
