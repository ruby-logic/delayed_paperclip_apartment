require 'delayed_paperclip_apartment/process_job'
require 'delayed_paperclip_apartment/attachment'
require 'delayed_paperclip_apartment/url_generator'
require 'delayed_paperclip_apartment/railtie' if defined?(Rails)

module DelayedPaperclipApartment
  class << self
    def options
      @options ||= {
        background_job_class: DelayedPaperclipApartment::ProcessJob,
        url_with_processing: true,
        processing_image_url: nil,
        queue: "paperclip"
      }
    end

    def processor
      options[:background_job_class]
    end

    def enqueue(instance_klass, instance_id, attachment_name)
      schema = Apartment::Tenant.current || nil
      processor.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name, schema)
    end

    def process_job(instance_klass, instance_id, attachment_name, schema)
      Apartment::Tenant.switch!(schema) if schema != nil

      instance = instance_klass.constantize.unscoped.where(id: instance_id).first
      return if instance.blank?

      instance.
        send(attachment_name).
        process_delayed!
    end

  end

  module Glue
    def self.included(base)
      base.extend(ClassMethods)
      base.send :include, InstanceMethods
    end
  end

  module ClassMethods

    def process_in_background(name, options = {})
      # initialize as hash
      paperclip_definitions[name][:delayed] = {}

      # Set Defaults
      only_process_default = paperclip_definitions[name][:only_process]
      only_process_default ||= []
      {
        priority: 0,
        only_process: only_process_default,
        url_with_processing: DelayedPaperclipApartment.options[:url_with_processing],
        processing_image_url: DelayedPaperclipApartment.options[:processing_image_url],
        queue: DelayedPaperclipApartment.options[:queue]
      }.each do |option, default|
        paperclip_definitions[name][:delayed][option] = options.key?(option) ? options[option] : default
      end

      # Sets callback
      if respond_to?(:after_commit)
        after_commit  :enqueue_delayed_processing
      else
        after_save    :enqueue_delayed_processing
      end
    end

    def paperclip_definitions
      if respond_to? :attachment_definitions
        attachment_definitions
      else
        Paperclip::Tasks::Attachments.definitions_for(self)
      end
    end
  end

  module InstanceMethods

    # First mark processing
    # then enqueue
    def enqueue_delayed_processing
      mark_enqueue_delayed_processing

      (@_enqued_for_processing || []).each do |name|
        enqueue_post_processing_for(name)
      end
      @_enqued_for_processing_with_processing = []
      @_enqued_for_processing = []
    end

    # setting each inididual NAME_processing to true, skipping the ActiveModel dirty setter
    # Then immediately push the state to the database
    def mark_enqueue_delayed_processing
      unless @_enqued_for_processing_with_processing.blank? # catches nil and empty arrays
        updates = @_enqued_for_processing_with_processing.collect{|n| "#{n}_processing = :true" }.join(", ")
        updates = ActiveRecord::Base.send(:sanitize_sql_array, [updates, {:true => true}])
        self.class.unscoped.where(:id => self.id).update_all(updates)
      end
    end

    def enqueue_post_processing_for name
      DelayedPaperclipApartment.enqueue(self.class.name, read_attribute(:id), name.to_sym)
    end

    def prepare_enqueueing_for name
      if self.attributes.has_key? "#{name}_processing"
        write_attribute("#{name}_processing", true)
        @_enqued_for_processing_with_processing ||= []
        @_enqued_for_processing_with_processing << name
      end

      @_enqued_for_processing ||= []
      @_enqued_for_processing << name
    end
  end
end
