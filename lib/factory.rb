# frozen_string_literal: true

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
# - size/length done
# - members done
# - select done
# - to_a done
# - values_at done
# - ==, eql? done

class Factory
  attr_accessor :name, :new_class

  def self.new(*class_arguments, &code_block)
    if class_arguments[0].instance_of? String
      @name = class_arguments[0]
      class_arguments.delete_at(0)
    end

    @new_class = Class.new do
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

      def length
        instance_variables.length
      end
      alias :size :length

      define_method :select do |&method|
        attributes_values.select(&method)
      end

      define_method :members do
        class_attributes
      end

      def ==(obj)
        raise TypeError, 'Obj is nil' if obj.nil?

        return false unless instance_variables == obj.instance_variables

        return true if attributes_values == obj.attributes_values

        false
      end
      alias :eql? :==

      define_method :to_a do
        attributes_values
      end

      define_method :each_pair do |&block|
        class_attributes.zip(attributes_values).to_h.each(&block)
      end

      define_method :each do |&block|
        attributes_values.each(&block)
      end

      define_method :dig do |*args|
        # dig into
      end

      define_method :attributes_values do
        instance_variables.map { |symbol| instance_variable_get symbol }
      end

      class_eval(&code_block) if block_given?
    end

    self.const_set(@name, @new_class)
  end
end