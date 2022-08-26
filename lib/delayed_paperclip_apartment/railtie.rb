require "paperclip"
require "delayed_paperclip_apartment"

module DelayedPaperclipApartment 
  # On initialzation, include DelayedPaperclipApartment 
  class Railtie < Rails::Railtie
    initializer "delayed_paperclip.insert_into_active_record" do |app|
      ActiveSupport.on_load :active_record do
        DelayedPaperclipApartment::Railtie.insert
      end

      if app.config.respond_to?(:delayed_paperclip_defaults)
        DelayedPaperclipApartment.options.merge!(app.config.delayed_paperclip_defaults)
      end
    end
  end

  class Railtie
    # Glue includes DelayedPaperclipApartment Class Methods and Instance Methods into ActiveRecord
    # Attachment and URL Generator extends Paperclip
    def self.insert
      ActiveRecord::Base.send(:include, DelayedPaperclipApartment::Glue)
      Paperclip::Attachment.prepend(DelayedPaperclipApartment::Attachment)
      Paperclip::Attachment.default_options[:url_generator] = DelayedPaperclipApartment::UrlGenerator
    end
  end
end
