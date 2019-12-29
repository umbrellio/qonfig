# frozen_string_literal: true

# @api private
# @since 0.19.0
class Qonfig::Plugins::PrettyPrint
  # @api private
  # @since 0.21.0
  module DataSetMixin
    # @param pp [?] Suitable for Ruby's PP module
    # @return [void]
    #
    # @api public
    # @since 0.19.0
    def pretty_print(pp)
      pp.object_address_group(self) do
        pp.seplist(keys, proc { pp.text(',') }) do |key|
          pp.breakable(' ')
          pp.group(1) do
            pp.text(key)
            pp.text(':')
            pp.breakable
            pp.pp(self[key])
          end
        end
      end
    end
  end

  # @api private
  # @since 0.21.0
  module CompactedConfigMixin
    # @param pp [?] Suitable for Ruby's PP module
    # @return [void]
    #
    # @api public
    # @since 0.21.0
    def pretty_print(pp)
      pp.object_address_group(self) do
        pp.seplist(@____data_set____.keys, ::Kernel.proc { pp.text(',') }) do |key|
          pp.breakable(' ')
          pp.group(1) do
            pp.text(key)
            pp.text(':')
            pp.breakable
            pp.pp(@____data_set____[key])
          end
        end
      end

      # NOTE: works only with this patch:
      <<~RUBY_2_7_PATCH
      class PP < PrettyPrint
        # ...

        module PPMethods
          # ...

          def pp(obj)
            # If obj is a Delegator then use the object being delegated to for cycle
            # detection

            if defined?(::Delegator) and (
              begin
                (class << obj; self; end) <= ::Delegator
              rescue TypeError
                obj.is_a?(::Delegator)
              end
            )
              obj = obj.__getobj__
            end # instead of: obj = obj.__getobj__ if defined?(::Delegator) and obj.is_a?(::Delegator)

            # ...
          end

          # ...
        end

        # ...
      end
      RUBY_2_7_PATCH
    end

    # @return [Integer]
    #
    # @see Object#object_id
    # @see BasicObject#__id__
    #
    # @api public
    # @since 0.21.0
    alias_method :object_id, :__id__
  end

  # @api private
  # @since 0.21.0
  module SettingsMixin
    # @param pp [?] Suitable for Ruby's PP module
    # @return [void]
    #
    # @api public
    # @since 0.21.0
    def pretty_print(pp)
      pp.object_address_group(self) do
        pp.seplist(__keys__, proc { pp.text(',') }) do |key|
          pp.breakable(' ')
          pp.group(1) do
            pp.text(key)
            pp.text(':')
            pp.breakable
            pp.pp(self[key])
          end
        end
      end
    end
  end
end
