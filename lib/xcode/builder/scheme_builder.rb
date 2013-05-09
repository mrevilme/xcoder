module Xcode

  class Workspace
    def to_xcodebuild_option
      "-workspace \"#{self.path}\""
    end
  end

  class Project
    def to_xcodebuild_option
      "-project \"#{self.path}\""
    end
  end

  module Builder
    class SchemeBuilder < BaseBuilder

      def initialize(scheme)
        @scheme     = scheme
        @target     = @scheme.build_targets.last
        super @target, @target.config(@scheme.archive_config)
      end

      def prepare_xcodebuild sdk=nil
        cmd = super sdk
        cmd << @scheme.parent.to_xcodebuild_option
        cmd << "-scheme \"#{@scheme.name}\""
        cmd << "-configuration \"#{@scheme.archive_config}\""
        cmd
      end

      def prepare_test_command sdk=@sdk
        cmd = "xctool -r"
        cmd << "-workspace #{@scheme.parent.name}.xcworkspace"
        cmd << "-scheme #{@scheme.name}"
        cmd << " test"
        cmd
      end

      def scheme
        @scheme
      end

      #
      # Invoke the configuration's test target and parse the resulting output
      #
      # If a block is provided, the report is yielded for configuration before the test is run
      #
      # TODO: Move implementation to the Xcode::Test module
      def test options = {:sdk => 'iphonesimulator', :show_output => true}
        report = Xcode::Test::Report.new
        print_task :builder, "Testing #{product_name}", :notice

        cmd = prepare_test_command options[:sdk]||@sdk

        # if block_given?
        #   yield(report)
        # else
        #   report.add_formatter :stdout, { :color_output => true }
        #   report.add_formatter :junit, 'test-reports'
        # end

        # cmd.attach Xcode::Test::Parsers::OCUnitParser.new(report)
        # cmd.show_output = options[:show_output] # override it if user wants output
        # begin
          # cmd.execute
        # rescue Xcode::Shell::ExecutionError => e
          # FIXME: Perhaps we should always raise this?
          # raise e if report.suites.count==0
        # end

        # report
      end


      # def prepare_build_command sdk=nil
      #   cmd = super sdk
      #   cmd << 'archive'
      #   cmd
      # end

    end
  end
end
