module SharedPublishableMethods
  extend ActiveSupport::Concern

  included do

    # Params:
    #   user [User]
    #
    # Returns:
    #   [Publishing]
    #
    # Requesting publishing will create a Publishing record which
    # carries the information of who submitted the request.
    def request_publishing_by(user)
      Publishing.create(user: user)
    end

    # Params:
    #
    # Returns:
    #   [Publishing]
    #
    # Requesting publishing will create a Publishing record which
    # carries the information of who submitted the request.
    def request_publishing
      Publishing.create(user: User.current)
    end
  end

  class_methods do
  end
end
