require File.dirname(__FILE__) + "/notifier/base"

module Integrity
  class Notifier
    include DataMapper::Resource

    property :id,      Integer,  :serial => true
    property :name,    String,   :nullable => false
    property :enabled, Boolean,  :nullable => false, :default => false
    property :config,  Yaml,     :nullable => false, :lazy    => false

    belongs_to :project, :class_name => "Integrity::Project",
                         :child_key => [:project_id]

    validates_is_unique :name, :scope => :project_id
    validates_present :project_id

    def self.available
      @@_notifiers ||= {}
      @@_notifiers
    end

    def self.register(klass)
      available[klass.to_s.split(":").last] = klass
    end

    def notify_of_build(build)
      to_const.notify_of_build(build, config) if to_const
    end

    private
      def to_const
        self.class.available[name]
      end
  end
end
