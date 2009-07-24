module MongoMapper
  module EmbeddedDocumentRailsCompatibility
    def self.included(model)
      model.class_eval do
        extend ClassMethods
      end
      class << model
        alias_method :has_many, :many
      end
    end

    module ClassMethods
      def column_names
        keys.keys
      end
    end

    def to_param
      raise "Missing to_param method in #{self.class.name}. You should implement it to return the unique identifier of this document within a collection."
    end
  end
end