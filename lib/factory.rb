# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each
# - each_pair
# - dig
# - size/length
# - members
# - select
# - to_a
# - values_at
# - ==, eql?

# frozen_string_literal: true

class Factory
  def self.new(*class_arguments, &code_block)
    Class.new do
      attr_accessor(*class_arguments)

      define_method :class_attributes do
        class_arguments
      end

      def initialize(*argument_values)
        raise ArgumentError, 'Wrong count of args' if argument_values.length != class_attributes.length

        instance_hash = class_attributes.zip(argument_values)
        instance_hash.each do |attribute, value|
          instance_variable_set("@#{attribute}", value)
        end
      end

      def [](argument)
        if argument.instance_of? Integer
          raise IndexError, 'No such attribute' unless (0...class_attributes.length).cover?(argument)

          inst_name = instance_variables[argument]
        else
          inst_name = "@#{argument}"
        end
        instance_variable_get(inst_name)
      end

      def length
        instance_variables.length
      end

      def size
        instance_variables.length
      end

      class_eval(&code_block) if block_given?
    end
  end
end
