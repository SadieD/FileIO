require "csv"
require "sunlight/congress"
require "erb"

Sunlight::Congress.api_key = 'e179a6973728c4dd3fb1204283aaccb5'

class Contact
  attr_accessor :name_first, :name_last, :zipcode, :legislators
  
  def initialize(name_first, name_last, zipcode, legislators)
    @name_first = name_first
    @name_last = name_last
    @zipcode = zipcode
    @legislators = legislators
  end
  
  def get_binding()
    binding()
  end
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislator_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_form_letter(erb_template, contact)
  form_letter = erb_template.result(contact.get_binding)
  time = Time.now
  dir_name = "output_#{time.strftime("%Y-%m-%d")}"
  
  Dir.mkdir(dir_name) unless Dir.exists? dir_name
  filename = "#{dir_name}/thanks_#{contact.object_id}.html"
  
  File.open(filename, 'w') {|file| file.puts form_letter}
end

puts "Event Manager Initialized"

filename = ARGV[0].to_s

begin
  contents = CSV.open(filename, headers: true, header_converters: :symbol)
ensure
  puts "Enter a valid csv filename as an arguement."
  exit(1)
end
  
template_letter = File.read "form_letter.html"
erb_template = ERB.new template_letter

contacts = []

contents.each_with_index do |row,i|
  zip = clean_zipcode(row[:zipcode])
  contacts << Contact.new(row[:first_name], row[:last_name], zip, legislator_by_zipcode(zip) )
  save_form_letter(erb_template, contacts.last)
end
