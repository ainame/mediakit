require 'active_support/core_ext/module/introspection'

module Mediakit
  module Utils
    module ConstantClassDefiner
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def using_attributes
          raise(NotImplementedError)
        end

        def define_subclass(klass, attributes)
          raise(
            ArgumentError,
            <<EOS
you can give attribute keys which only defined by `using_attributes` and that is satisfied all keys.'
EOS
          ) unless Set.new(using_attributes) == Set.new(attributes.keys)

          klass_name = klass.to_s
          return if parent.const_defined?(klass_name)

          parent.const_set(
            klass_name,
            Class.new(self) do
              attributes.each do |key, val|
                define_singleton_method(key) do
                  val
                end
              end
              private_class_method :new
            end.freeze
          )
        end
      end
    end
  end
end
