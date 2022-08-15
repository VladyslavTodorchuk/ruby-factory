# frozen_string_literal: true

# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each done
# - each_pair done
# - dig done
# - size/length done
# - members done
# - select done
# - to_a done
# - values_at done
# - ==, eql? done

class Factory
  class << self
    def new(*class_arguments, &code_block)
      if class_arguments[0].instance_of? String
        name = class_arguments[0]
        class_arguments.delete_at(0)
        self.const_set(name, create_class(*class_arguments,&code_block))
      else
        create_class(*class_arguments,&code_block)
      end
    end

    def create_class(*class_arguments, &code_block)
      Class.new do
        attr_accessor(*class_arguments)

        define_method :initialize do |*argument_values|
          raise ArgumentError, 'Wrong count of args' if argument_values.size != class_arguments.size

          instance_hash = class_arguments.zip(argument_values)
          instance_hash.each do |attribute, value|
            instance_variable_set("@#{attribute}", value)
          end
        end

        define_method :[] do |argument|
          inst_name = argument.is_a?(Integer) ? instance_variables[argument] : "@#{argument}"
          instance_variable_get(inst_name)
        end

        define_method :[]= do |argument, value|
          inst_name = argument.is_a?(Integer) ? instance_variables[argument] : "@#{argument}"
          instance_variable_set(inst_name, value)
        end

        define_method :values_at do |*values|
          to_a.values_at(*values)
        end

        def length
          instance_variables.length
        end
        alias :size :length

        define_method :select do |&method|
          attributes_values.select(&method)
        end

        define_method :members do
          class_arguments
        end

        def ==(obj)
          raise TypeError, 'Obj is nil' if obj.nil?

          self.class == obj.class && self.to_a == obj.to_a
        end
        alias :eql? :==

        define_method :to_a do
          attributes_values
        end

        define_method :each_pair do |&block|
          members.zip(attributes_values).to_h.each(&block)
        end

        define_method :each do |&block|
          attributes_values.each(&block)
        end

        define_method :dig do |*args|
          args.inject(self) { |value, elem| value[elem] if value }
        end

        define_method :attributes_values do
          instance_variables.map { |symbol| instance_variable_get symbol }
        end

        class_eval(&code_block) if block_given?
      end
    end
  end
end