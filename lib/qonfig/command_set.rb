# frozen_string_literal: true

# @api private
# @since 0.1.0
class Qonfig::CommandSet
  # @api private
  # @since 0.13.0
  include Enumerable

  # @return [Array<Qonfig::Commands::Base>]
  #
  # @api private
  # @since 0.1.0
  attr_reader :commands

  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def initialize
    @commands = []
    @access_lock = Mutex.new
  end

  # @param command [Qonfig::Commands::Base]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def add_command(command)
    thread_safe { commands << command }
  end
  alias_method :<<, :add_command

  # @param block [Proc]
  # @return [Enumerable]
  #
  # @api private
  # @since 0.1.0
  def each(&block)
    thread_safe { block_given? ? commands.each(&block) : commands.each }
  end

  # @param command_set [Qonfig::CommandSet]
  # @param concat_condition [Block]
  # @yield [command]
  # @yieldparam command [Qonfig::Commands::Base]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  # @version 0.19.0
  def concat(command_set, &concant_condition)
    thread_safe do
      if block_given?
        command_set.each { |command| (commands << command) if yield(command) }
      else
        command_set.each { |command| commands << command }
      end
    end
  end

  # @return [Qonfig::CommandSet]
  #
  # @api private
  # @since 0.2.0
  def dup
    thread_safe do
      self.class.new.tap { |duplicate| duplicate.concat(self) }
    end
  end

  private

  # @param block [Proc]
  # @return [Any]
  #
  # @api private
  # @since 0.2.0
  # @version 0.19.0
  def thread_safe(&block)
    @access_lock.owned? ? yield : @access_lock.synchronize(&block)
  end
end
