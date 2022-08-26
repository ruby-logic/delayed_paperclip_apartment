require "active_job"

module DelayedPaperclipApartment 
  class ProcessJob < ActiveJob::Base
    def self.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name, schema)
      queue_name = instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:queue]

      set(:queue => queue_name).perform_later(instance_klass, instance_id, attachment_name.to_s, schema)
    end

    def perform(instance_klass, instance_id, attachment_name, schema)
      DelayedPaperclipApartment.process_job(instance_klass, instance_id, attachment_name.to_sym, schema)
    end
  end
end
