# Rakefile for ConTeXt documents
#
# Author: Tim Steenvoorden
# Last Changed: 2 Sep 2009
#
require 'pathname'

# Extend Pathname with each_parent method
class Pathname

	def each_parent
		if self.directory?
			dir = self
		else
			dir = self.parent
		end

		until dir.root?
			yield dir
			dir = dir.parent
		end
	end

end

# Determine build files
pwd = Pathname.pwd

STAM = pwd.split.last.to_s.sub(/\s/, '').downcase
PRODUCT = STAM + '.pdf'
SOURCE = STAM + '.tex'

COMPONENTS = FileList.new('_*.tex')
ENVIRONMENTS = FileList.new
pwd.each_parent do |p|
	ENVIRONMENTS.include "#{p}/*{Layout,Definitions}.tex"
end

# Default options
$engine = 'xetex'
$mode = ''

# Define PDF-creation rule
rule '.pdf' => '.tex' do |t|
	sh "texexec --engine=#{$engine} --mode=#{$mode} #{t.source}"
end

# Define tasks
desc "Build document and open it with default PDF-viewer"
task :show => PRODUCT do
	sh "open #{PRODUCT}"
end

desc "Purge all auxiliary files"
task :clean do
	sh "ctxtools --purge --all"
end

desc "Same as :clean, but also remove document"
task :clobber => :clean do
	rm_f PRODUCT
	rm_f COMPONENTS.collect {|e| e.sub(/\.tex$/, '.pdf') }#TODO: do...end in 2.0
end

desc "Show internal variables"
task :intern do
	format = "%15s: %p\n"
	printf format, "Product", PRODUCT
	printf format, "Source", SOURCE
	printf format, "Components", COMPONENTS
	printf format, "Environments", ENVIRONMENTS
	printf format, "Engine", $engine
	printf format, "Mode", $mode
end

desc "Build document (#{PRODUCT})"
task :default => PRODUCT

# Define product dependencies
file PRODUCT => SOURCE
file PRODUCT => COMPONENTS
file PRODUCT => ENVIRONMENTS

