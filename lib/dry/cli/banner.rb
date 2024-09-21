# frozen_string_literal: true

require "dry/cli/program_name"

module Dry
  class CLI
    # Command banner
    #
    # @since 0.1.0
    # @api private
    module Banner
      # Prints command banner
      #
      # @param command [Dry::CLI::Command] the command
      # @param out [IO] standard output
      #
      # @since 0.1.0
      # @api private
      def self.call(command, name)
        [
          command_name(name),
          command_name_and_arguments(command, name),
          command_description(command),
          command_subcommands(command),
          command_arguments(command),
          command_options(command),
          command_examples(command, name)
        ].compact.join("\n")
      end

      # @since 0.1.0
      # @api private
      def self.command_name(name)
        "Command:\n  #{name}"
      end

      # @since 0.1.0
      # @api private
      def self.command_name_and_arguments(command, name)
        usage = "\nUsage:\n  #{name}#{arguments(command)}"

        return usage + " | #{name} SUBCOMMAND" if command.subcommands.any?

        usage
      end

      # @since 0.1.0
      # @api private
      def self.command_examples(command, name)
        return if command.examples.empty?

        "\nExamples:\n#{command.examples.map { |example| "  #{name} #{example}" }.join("\n")}"
      end

      # @since 0.1.0
      # @api private
      def self.command_description(command)
        return if command.description.nil?

        "\nDescription:\n  #{command.description}"
      end

      def self.command_subcommands(command)
        return if command.subcommands.empty?

        "\nSubcommands:\n#{build_subcommands_list(command.subcommands)}"
      end

      # @since 0.1.0
      # @api private
      def self.command_arguments(command)
        return if command.arguments.empty?

        "\nArguments:\n#{extended_command_arguments(command)}"
      end

      # @since 0.1.0
      # @api private
      def self.command_options(command)
        "\nOptions:\n#{extended_command_options(command)}"
      end

      # @since 0.1.0
      # @api private
      def self.arguments(command)
        required_arguments = command.required_arguments
        optional_arguments = command.optional_arguments

        required = required_arguments.map { |arg| arg.name.upcase }.join(" ") if required_arguments.any? # rubocop:disable Metrics/LineLength
        optional = optional_arguments.map { |arg| "[#{arg.name.upcase}]" }.join(" ") if optional_arguments.any? # rubocop:disable Metrics/LineLength
        result = [required, optional].compact

        " #{result.join(" ")}" unless result.empty?
      end

      # @since 0.1.0
      # @api private
      def self.extended_command_arguments(command)
        command.arguments.map do |argument|
          "  #{argument.name.to_s.upcase.ljust(32)}  # #{"REQUIRED " if argument.required?}#{argument.desc}" # rubocop:disable Metrics/LineLength
        end.join("\n")
      end

      # @since x.x.x
      # @api private
      def self.simple_option(option)
        name = Inflector.dasherize(option.name)
        name = if option.boolean?
                 "[no-]#{name}"
               elsif option.array?
                 "#{name}=VALUE1,VALUE2,.."
               else
                 "#{name}=VALUE"
               end
        name = "#{name}, #{option.alias_names.join(", ")}" if option.aliases.any?
        "--#{name}"
      end

      # @since x.x.x
      # @api private
      def self.extended_option(option)
        name = "  #{simple_option(option).ljust(32)}  # #{"REQUIRED " if option.required?}#{option.desc}" # rubocop:disable Metrics/LineLength
        name = "#{name}, default: #{option.default.inspect}" unless option.default.nil?
        name
      end

      # @since 0.1.0
      # @api private
      #
      def self.extended_command_options(command)
        result = command.options.map do |option|
          extended_option(option)
        end

        result << "  --#{"help, -h".ljust(30)}  # Print this help"
        result.join("\n")
      end

      def self.build_subcommands_list(subcommands)
        subcommands.map do |subcommand_name, subcommand|
          "  #{subcommand_name.ljust(32)}  # #{subcommand.command.description}"
        end.join("\n")
      end
    end
  end
end
