module MongoMapper
  module Associations
    class PolymorphicHasManyEmbeddedProxy < Proxy
      def replace(v)
        @_values = v.map do |e|
          ref_type = "#{@association.name}_type"
          if e.kind_of?(EmbeddedDocument)  
            e.class.send(:key, ref_type, String)
            {ref_type => e.class.name}.merge(e.attributes)
          else
            e
          end
        end
        
        @target = nil

        reload_target
      end

      protected
      def find_target
        (@_values || []).map do |e|
          ref_type = "#{@association.name}_type"
          class_name = e[ref_type]
          klass = class_name ? Kernel.const_get(class_name) : @association.klass
          klass.new(e)
        end
      end
    end
  end
end