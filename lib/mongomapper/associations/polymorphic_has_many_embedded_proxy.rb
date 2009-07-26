module MongoMapper
  module Associations
    class PolymorphicHasManyEmbeddedProxy < ArrayProxy      
      def replace(v)
        @_values = v.map do |doc_or_hash|
          if doc_or_hash.kind_of?(EmbeddedDocument)
            doc = doc_or_hash
            {@association.type_key_name => doc.class.name}.merge(doc.attributes)
          else
            doc_or_hash
          end
        end
        
        @target = nil
        reload_target
      end
      
      def <<(*docs)
        load_target if @owner.new?
        
        flatten_deeper(docs).each do |doc|
          doc.send("#{@association.type_key_name}=", doc.class)
          @target << doc
        end
        
        self
      end
      alias_method :push, :<<
      alias_method :concat, :<<

      protected
        def find_target
          (@_values || []).map do |hash|
            polymorphic_class(hash).new(hash)
          end
        end
        
        def polymorphic_class(doc)
          if class_name = doc[@association.type_key_name]
            class_name.constantize
          else
            @association.klass
          end
        end
    end
  end
end