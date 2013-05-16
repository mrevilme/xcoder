require 'plist'
require 'pp'
require 'cfpropertylist'


module Xcode
  
  #
  # @see https://developer.apple.com/library/ios/#documentation/general/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html
  # 
  class InfoPlist
    def initialize(config, plist_location)
      @config = config
      
      @data_location = File.expand_path("#{File.dirname(@config.target.project.path)}/#{plist_location}")
      unless File.exists?(@data_location)
        puts 'Plist not found ' + @data_location
        exit 1
      end
      @plist = CFPropertyList::List.new(:file => @data_location)
      @data = CFPropertyList.native_types(@plist.value)


       #Plist::parse_xml(@data_location)
    end

    def marketing_version
      @data['CFBundleShortVersionString']
    end

    def marketing_version=(version)
      @data['CFBundleShortVersionString'] = version
    end

    def version
      @data['CFBundleVersion']
    end

    def version=(version)
      @data['CFBundleVersion'] = version.to_s
    end

    def identifier
      @data['CFBundleIdentifier']
    end

    def identifier=(identifier)
      @data['CFBundleIdentifier'] = identifier
    end

    def display_name
      @data['CFBundleDisplayName']
    end

    def display_name=(name)
      @data['CFBundleDisplayName'] = name
    end

    def save
      plist = CFPropertyList::List.new 
      plist.value = CFPropertyList.guess(@data)
      plist.save(@data_location, CFPropertyList::List::FORMAT_XML)
      # File.open(@data_location, 'w') {|f| f << @data.to_plist}
    end
  end
end