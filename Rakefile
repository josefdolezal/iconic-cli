#!/usr/bin/rake
require 'pathname'
require 'yaml'
require 'json'
require 'net/http'
require 'uri'



## [ Constants ] ##############################################################

BIN_NAME = 'iconic'
DEPENDENCIES = [:PathKit, :Stencil, :Commander]
CONFIGURATION = 'Release'
BUILD_DIR = 'build/' + CONFIGURATION
TEMPLATES_SRC_DIR = 'templates'



## [ Utils ] ##################################################################

def version_select
  # Find all Xcode 8 versions on this computer
  xcodes = `mdfind "kMDItemCFBundleIdentifier = 'com.apple.dt.Xcode' && kMDItemVersion = '8.*'"`.chomp.split("\n")
  if xcodes.empty?
    raise "\n[!!!] You need to have Xcode 8.x to compile Iconic.\n\n"
  end
  # Order by version and get the latest one
  vers = lambda { |path| `mdls -name kMDItemVersion -raw "#{path}"` }
  latest_xcode_version = xcodes.sort { |p1, p2| vers.call(p1) <=> vers.call(p2) }.last
  %Q(DEVELOPER_DIR="#{latest_xcode_version}/Contents/Developer" TOOLCHAINS=com.apple.dt.toolchain.XcodeDefault.xctoolchain)
end

def xcpretty(cmd)
  if `which xcpretty` && $?.success?
    sh "set -o pipefail && #{cmd} | xcpretty -c"
  else
    sh cmd
  end
end

def xcrun(cmd)
  xcpretty "#{version_select} xcrun #{cmd}"
end

def print_info(str)
  (red,clr) = (`tput colors`.chomp.to_i >= 8) ? %W(\e[33m \e[m) : ["", ""]
  puts red, "== #{str.chomp} ==", clr
end

def defaults(args)
  bindir = args.bindir.nil? || args.bindir.empty? ? Pathname.new('./build/iconic/bin') : Pathname.new(args.bindir)
  fmkdir = args.fmkdir.nil? || args.fmkdir.empty? ? bindir + '../lib' : Pathname.new(args.fmkdir)
  tpldir = args.tpldir.nil? || args.tpldir.empty? ? bindir + '../templates' : Pathname.new(args.tpldir)
  [bindir, fmkdir, tpldir].map(&:expand_path)
end


## [ Build Tasks ] ############################################################

desc "Build the CLI binary and its frameworks in #{BUILD_DIR}"
task :build, [:bindir, :tpldir] => DEPENDENCIES.map { |dep| "dependencies:#{dep}" } do |_, args|
  (bindir, _, tpldir) = defaults(args)
  tpl_rel_path = tpldir.relative_path_from(bindir)
  main = File.read('Iconic/main.swift')
  File.write('Iconic/main.swift', main.gsub(/^let templatesRelativePath = .*$/, %Q(let templatesRelativePath = "#{tpl_rel_path}")))

  print_info "Building Binary"
  frameworks = DEPENDENCIES.map { |fmk| "-framework #{fmk}" }.join(" ")
  search_paths = DEPENDENCIES.map { |fmk| "-F #{BUILD_DIR}/#{fmk}" }.join(" ")
  xcrun %Q(-sdk macosx swiftc -O -o #{BUILD_DIR}/#{BIN_NAME} #{search_paths}/ #{frameworks} Iconic/*.swift Iconic/parsers/*.swift)
end

namespace :dependencies do
  DEPENDENCIES.each do |fmk|
    # desc "Build #{fmk}.framework"
    task fmk do
      print_info "Building #{fmk}.framework"
      xcrun %Q(xcodebuild -project Pods/Pods.xcodeproj -target #{fmk} -configuration #{CONFIGURATION})
    end
end
end

desc "Build the CLI and link it so it can be run from #{BUILD_DIR}. Useful for testing without installing."
task :link => :build do
  sh %Q(install_name_tool -add_rpath "@executable_path" #{BUILD_DIR}/#{BIN_NAME})
end



## [ Install Tasks ] ##########################################################

desc "Install the binary in $bindir, frameworks — without the Swift dylibs — in $fmkdir, and templates in $tpldir\n" \
     "(defaults $bindir=./build/swiftgen/bin/, $fmkdir=$bindir/../lib, $tpldir=$bindir/../templates"
task 'install:light', [:bindir, :fmkdir, :tpldir] => :build do |_, args|
  (bindir, fmkdir, tpldir) = defaults(args)

  print_info "Installing binary in #{bindir}"
  sh %Q(mkdir -p "#{bindir}")
  sh %Q(cp -f "#{BUILD_DIR}/#{BIN_NAME}" "#{bindir}")

  print_info "Installing frameworks in #{fmkdir}"
  sh %Q(mkdir -p "#{fmkdir}")
  DEPENDENCIES.each do |fmk|
    sh %Q(cp -fr "#{BUILD_DIR}/#{fmk}/#{fmk}.framework" "#{fmkdir}")
  end
  sh %Q(install_name_tool -add_rpath "@executable_path/#{fmkdir.relative_path_from(bindir)}" "#{bindir}/#{BIN_NAME}")

  print_info "Installing templates in #{tpldir}"
  sh %Q(mkdir -p "#{tpldir}")
  sh %Q(cp -r "#{TEMPLATES_SRC_DIR}/" "#{tpldir}")
end

desc "Install the binary in $bindir, frameworks — including Swift dylibs — in $fmkdir, and templates in $tpldir\n" \
     "(defaults $bindir=./swiftgen/bin/, $fmkdir=$bindir/../lib, $tpldir=$bindir/../templates"
task :install, [:bindir, :fmkdir, :tpldir] => 'install:light' do |_, args|
  (bindir, fmkdir, tpldir) = defaults(args)

  print_info "Linking to standalone Swift dylibs"
  xcrun %Q(swift-stdlib-tool --copy --scan-executable "#{bindir}/#{BIN_NAME}" --platform macosx --destination "#{fmkdir}")
  toolchain_dir = `#{version_select} xcrun -find swift-stdlib-tool`.chomp
  xcode_rpath = File.dirname(File.dirname(toolchain_dir)) + '/lib/swift/macosx'
  xcrun %Q(install_name_tool -delete_rpath "#{xcode_rpath}" "#{bindir}/#{BIN_NAME}")
end
