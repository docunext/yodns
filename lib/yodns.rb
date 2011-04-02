require 'zonefile'

class YoDns

  attr_accessor :zone
  attr_accessor :record_type

  def record_report
    rect = @record_type.to_sym
    rr = @zone.send(rect) 
    th = rr.first.keys
    th.delete(:class)
    th.insert(0,th.pop) << 'record_type'
    t = table th
    rr.each do |za|
      za.delete(:class)
      tr = za.values
      tr = tr.insert(0,tr.pop) << @record_type
      t << tr
    end
    puts t
  end

  def load_zone(zone, origin=nil)
    file_name = "spec/#{zone}.zone"
    if File.exists?(file_name)
      @zone = Zonefile.new(File.read(file_name), file_name.split('/').last, origin)
    else
      #raise ZonefileNotFound.new(zone)
    end
  end
  def list_zone_records(zone, report_type)
    self.load_zone(zone)
    @record_type = report_type 
    self.record_report
  end
  def add_zone_record(zone, type, params = []) 
    self.load_zone(zone)
    @zone.add_record(type, { :class => 'IN', :name => params[0], :host => params[1], :ttl => params[2] })
    puts "Added #{params[0]} pointing to #{params[1]} "
    @record_type = type
    self.record_report
  end

# File lib/zonefile/zonefile.rb, line 219
 def output
    out =<<-ENDH
;  Database file #{@filename || 'unknown'} for #{@origin || 'unknown'} zone.
;	Zone version: #{self.soa[:serial]}
;
#{self.soa[:ttl] ? "$TTL #{self.soa[:ttl]}" : ''}
#{self.soa[:origin]}		#{self.soa[:ttl]} IN  SOA  #{self.soa[:primary]} #{self.soa[:email]} (
				#{self.soa[:serial]}	; serial number
				#{self.soa[:refresh]}	; refresh
				#{self.soa[:retry]}	; retry
				#{self.soa[:expire]}	; expire
				#{self.soa[:minimumTTL]}	; minimum TTL
				)
; Zone NS Records
ENDH

   self.ns.each do |ns|
     out <<  "#{ns[:name]}      #{ns[:ttl]}  #{ns[:class]}    NS #{ns[:host]}\n"
   end
   out << "\n; Zone MX Records\n" unless self.mx.empty?
   self.mx.each do |mx|
     out << "#{mx[:name]}       #{mx[:ttl]}   #{mx[:class]}     MX  #{mx[:pri]} #{mx[:host]}\n"
   end
   
   self.a.each do |a|
     a[:name] = self.soa[:origin] if !a[:name]
        out <<  "#{a[:name]}    #{a[:ttl]} #{a[:class]}    A  #{a[:host]}\n"
   end   
   self.cname.each do |cn|
     cn[:name] = self.soa[:origin] if !cn[:name]
     out << "#{cn[:name]}       #{cn[:ttl]}   #{cn[:class]}     CNAME       #{cn[:host]}\n"
   end  
   self.a4.each do |a4|
     out << "#{a4[:name]}       #{a4[:ttl]}   #{a4[:class]}     AAAA        #{a4[:host]}\n"
   end
   self.txt.each do |tx|
     tx[:name] = self.soa[:origin] if !tx[:name]
     out << "#{tx[:name]}       #{tx[:ttl]}   #{tx[:class]}     TXT \"#{tx[:text]}\"\n"
   end
   self.srv.each do |srv|
     out << "#{srv[:name]}      #{srv[:ttl]} #{srv[:class]}  SRV      #{srv[:pri]} #{srv[:weight]} #{srv[:port]}   #{srv[:host]}\n"
   end
   
   out
 end



end
