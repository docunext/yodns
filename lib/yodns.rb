require 'zonefile'

class YoDns < Zonefile

  def self.from_file(file_name, origin = nil)
    if File.exists?(file_name)
      YoDns.new(File.read(file_name), file_name.split('/').last, origin)
    else
      #raise ZonefileNotFound.new(zone)
    end
  end

  def list_records
    @zonefile.a.each {|ar| puts ar }
  end

end
