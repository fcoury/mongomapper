module MongoMapper
  module Associations
    class PolymorphicHasManyEmbeddedProxy < ArrayProxy
      TypeKey = '_type'
      
      def replace(v)
        @_values = v.map do |e|
          if e.kind_of?(EmbeddedDocument)
            ensure_type_key_exists(e)
            {TypeKey => e.class.name}.merge(e.attributes)
          else
            e
          end
        end
        
        @target = nil
        reload_target
      end
      
      def <<(*docs)
        load_target if @owner.new?
        
        flatten_deeper(docs).each do |doc|
          ensure_type_key_exists(doc)
          doc.send("#{TypeKey}=", doc.class)
          @target << doc
        end
        
        self
      end
      alias_method :push, :<<
      alias_method :concat, :<<

      protected
        def find_target
          (@_values || []).map do |e|
            class_for(e).new(e)
          end
        end
        
        def ensure_type_key_exists(doc)
          doc.class.send(:key, TypeKey, String)
        end
        
        def class_for(doc)
          if class_name = doc[TypeKey]
            class_name.constantize
          else
            @association.klass
          end
        end
    end
  end
end