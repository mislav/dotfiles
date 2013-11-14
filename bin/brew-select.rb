require 'ostruct'
require 'keg'
require 'formula'

name, version = ARGV.named
if name.nil? || version.nil?
  $stderr.puts "Usage: brew select #{name || 'NAME'} VERSION"
  unless name.nil?
    kegs = (HOMEBREW_CELLAR + name).subdirs.map {|d| Keg.new(d) }.sort_by(&:version)
    versions = kegs.map {|k| v=k.version.to_s; v+='*' if k.linked?; v }
    $stderr.puts "Available versions: #{versions.join(' ')}"
  end
  exit 1
end
keg = Keg.new(HOMEBREW_CELLAR + name + version)

mode = OpenStruct.new
mode.overwrite = true
mode.dry_run = true if ARGV.dry_run?

if Formula.factory(keg.fname).keg_only?
  odie "#{keg.fname} is keg-only"
end

if mode.dry_run
  puts "Would link:"
  keg.link(mode)
else
  keg.lock do
    keg.unlink
    puts "Linking #{keg}... "
    puts "#{keg.link(mode)} symlinks created"
  end
end
