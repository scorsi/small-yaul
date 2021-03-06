require 'parser'
require 'runtime'

class Interpreter
  def initialize
    @parser = Parser.new
  end

  def eval(code)
    @parser.parse(code).eval(RootContext)
  end
end

class Nodes
  def eval(context)
    return_value = nil
    nodes.each do |node|
      return_value = node.eval(context)
    end
    return_value || Constants['nil']
  end
end

class NumberNode
  def eval(_context)
    Constants['Number'].new_with_value(value)
  end
end

class StringNode
  def eval(_context)
    Constants['String'].new_with_value(value)
  end
end

class TrueNode
  def eval(_context)
    Constants['true']
  end
end

class FalseNode
  def eval(_context)
    Constants['false']
  end
end

class NilNode
  def eval(_context)
    Constants['nil']
  end
end

class GetConstantNode
  def eval(_context)
    Constants[name]
  end
end

class GetLocalNode
  def eval(context)
    context.locals[name]
  end
end

class SetConstantNode
  def eval(context)
    Constants[name] = value.eval(context)
  end
end

class SetLocalNode
  def eval(context)
    context.locals[name] = value.eval(context)
  end
end

class CallNode
  def eval(context)
    value = if receiver
              receiver.eval(context)
            else
              context.current_self
            end

    evaluated_arguments = arguments.map { |arg| arg.eval(context) }
    value.call(method, evaluated_arguments)
  end
end

class DefNode
  def eval(context)
    method = AwesomeMethod.new(params, body)
    context.current_class.runtime_methods[name] = method
  end
end

class ClassNode
  def eval(_context)
    awesome_class = Constants[name]

    unless awesome_class
      awesome_class = AwesomeClass.new(Constants['Class'])
      Constants[name] = awesome_class
    end

    class_context = Context.new(awesome_class, awesome_class)
    body.eval(class_context)

    awesome_class
  end
end

class IfNode
  def eval(context)
    if condition.eval(context).ruby_value
      body.eval(context)
    else
      Constants['nil']
    end
  end
end
