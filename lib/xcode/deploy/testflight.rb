require 'rest-client'

module Xcode
  module Deploy
    class Testflight
      attr_accessor :api_token, :team_token, :notify, :proxy, :notes, :lists, :builder
      @@defaults = {}

      def self.defaults(defaults={})
        @@defaults = defaults
      end

      def initialize(builder, options={})
        @builder = builder
        @api_token = options[:api_token]||@@defaults[:api_token]
        @team_token = options[:team_token]||@@defaults[:team_token]
        @notify = options.has_key?(:notify) ? options[:notify] : true
        @notes = release_notes(options)
        @lists = options[:lists]||[]
        @proxy = ENV['http_proxy'] || ENV['HTTP_PROXY']
        @replace = options.has_key?(:replace) ? options[:replace] : false
      end

      def release_notes(options)
        notes = options[:notes]
        notes || get_notes_using_editor
      end

      def get_notes_using_editor
        return unless (editor = ENV["EDITOR"])

        dir = Dir.mktmpdir
        begin
          filepath = "#{dir}/release_notes"
          system("#{editor} #{filepath}")
          file_notes = File.read(filepath)
        ensure
          FileUtils.rm_rf(dir)
        end
        file_notes
      end

      def deploy
        puts "Uploading to Testflight..."

        # RestClient.proxy = @proxy || ENV['http_proxy'] || ENV['HTTP_PROXY']
        # RestClient.log = '/tmp/restclient.log'
        #
        # response = RestClient.post('http://testflightapp.com/api/builds.json',
        #   :file => File.new(builder.ipa_path),
        #   :dsym => File.new(builder.dsym_zip_path),
        #   :api_token => @api_token,
        #   :team_token => @team_token,
        #   :notes => @notes,
        #   :notify => @notify ? 'True' : 'False',
        #   :distribution_lists => @lists.join(',')
        # )
        #
        # json = JSON.parse(response)
        # puts " + Done, got: #{json.inspect}"
        # json

        cmd = Xcode::Shell::Command.new 'curl'
        cmd << "--proxy #{@proxy}" unless @proxy.nil? or @proxy==''
        cmd << "-X POST http://testflightapp.com/api/builds.json"
        cmd << "-F file=@\"#{@builder.ipa_path}\""
        cmd << "-F dsym=@\"#{@builder.dsym_zip_path}\"" unless @builder.dsym_zip_path.nil?
        cmd << "-F api_token='#{@api_token}'"
        cmd << "-F team_token='#{@team_token}'"
        cmd << "-F notes=\"#{@notes}\"" unless @notes.nil?
        cmd << "-F notify=#{@notify ? 'True' : 'False'}"
        cmd << "-F distribution_lists='#{@lists.join(',')}'" unless @lists.count==0
        cmd << "-F replace=#{@replace ? 'True' : 'False'}"

        response = Xcode::Shell.execute(cmd)

        json = MultiJson.load(response.join(''))
        puts " + Done, got: #{json.inspect}"

        yield(json) if block_given?

        json
      end
    end
  end
end
