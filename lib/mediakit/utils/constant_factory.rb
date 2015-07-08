module Mediakit
  module Utils
    module ConstantFactory
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
          attr_reader(*(base.using_attributes))

          def initialize(attributes)
            self.class.using_attributes.each do |key|
              instance_variable_set("@#{key}", attributes[key])
            end
          end
        end
      end

      module ClassMethods
        def using_attributes
          raise(NotImplementedError)
        end

        def create_constant(name, attributes)
          raise(
            ArgumentError,
            <<EOS
you can give attribute keys which only defined by `using_attributes` and that is satisfied all keys.'
EOS
          ) unless Set.new(using_attributes) == Set.new(attributes.keys)
          return self.const_get(name) if self.const_defined?(name)
          self.const_set(name, new(attributes).freeze)
        end
      end
    end
  end
end
