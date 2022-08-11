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
# - members done
# - select done
# - length/size done
# - to_a
# - [] done
# - []= done
# - values_at done
# - ==, eql? done

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

      define_method :[] do |argument|
        inst_name = if argument.instance_of? Integer
                      instance_variables[argument]
                    else
                      "@#{argument}"
                    end
        instance_variable_get(inst_name)
      end

      define_method :[]= do |argument, value|
        inst_name = if argument.instance_of? Integer
                      instance_variables[argument]
                    else
                      "@#{argument}"
                    end
        instance_variable_set(inst_name, value)
      end

      define_method :values_at do |*values|
        if values.instance_of? Array
          instances = []
          values.each { |element| instances << instance_variable_get(instance_variables[element]) }
          return instances
        end
        instance_variable_get(instance_variables[values])
      end

      define_method :length do
        instance_variables.length
      end

      define_method :size do
        instance_variables.length
      end

      define_method :select do |&method|
        instances = []
        instance_variables.each { |instant| instances << instance_variable_get(instant) }
        instances.select(&method)
      end

      define_method :members do
        class_attributes
      end

      define_method :== do |obj|
        raise TypeError, 'Obj is nil' if obj.nil?

        return false unless instance_variables == obj.instance_variables

        return true if attributes == obj.attributes

        false
      end

      define_method :attributes do
        instance_variables.map { |symbol| instance_variable_get symbol }
      end

      class_eval(&code_block) if block_given?
    end
  end
end
