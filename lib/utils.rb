require "colorize"
require "json"

module Utils
  YES = "\u2714".green
  NO  = "\u2718".red

  BASE_PORT = 9292

  def h1(str, color: :cyan)
    puts
    puts ("=" * 80).colorize(color)
    puts
    puts str.center(80).colorize(color)
    puts
    puts ("=" * 80).colorize(color)
    puts
  end

  def h2(str, color: :magenta)
    puts
    puts " #{str} ".center(80, "-").colorize(color)
    puts
  end

  def run(cmd, silent: false, allow_failure: false, **opts)
    if silent
      system("#{cmd} > /dev/null 2> /dev/null", opts)
    else
      puts "$ ".yellow + cmd
      system(cmd, opts)
    end

    if $?.success?
      true
    elsif allow_failure
      false
    else
      error! "Failed to run `#{cmd}`: command exited with status #{$?.exitstatus}"
    end
  end

  def error!(message)
    h1 "ERROR", color: :red
    puts message
    puts
    exit 1
  end

  def check(title, success = :use_block, info: nil, filler: ".", error_message: nil)
    filler_count = 80

    filler_count -= title.length
    filler_count -= 1 # Space after title

    if info
      filler_count -= info.length
      filler_count -= 1 # Space before info
    end

    filler_count -= 1 # Space before the check mark
    filler_count -= 2 # The checkmark itself

    seperator = filler * filler_count

    print "#{title} #{seperator} "

    if success == :use_block
      success = yield
    end

    if info
      print "#{info} "
    end

    puts success ? Utils::YES : Utils::NO

    if !success && error_message
      error! error_message
    end
  end

  def check_version(component, cmd, pattern, requirement)
    output  = `#{cmd} 2>&1`
    version = $?.success? && output =~ pattern && $1

    if version
      requirement = Gem::Requirement.new(requirement)
      satisfied   = requirement.satisfied_by?(Gem::Version.new(version))
      check component, satisfied, info: version, error_message: "Cannot find a compatible version of #{component.strip}"
    else
      check component, false, info: "N/A", error_message: "Cannot find a compatible version of #{component.strip}"
    end
  end

  def check_command(title, cmd, **options)
    check(title, **options) do
      run(cmd, silent: true, allow_failure: true)
    end
  end

  def full_path(path)
    File.expand_path(File.join("..", "..", path), __FILE__)
  end

  def exists?(path, expand: true)
    path = full_path(path) if expand
    File.exists?(path)
  end

  def read_file(path, expand: true)
    path = full_path(path) if expand
    File.read(path)
  end

  def directory?(path, expand: true)
    path = full_path(path) if expand
    File.directory?(path)
  end

  def valid_json?(path, **options)
    begin
      parse_json(path, **options)
      true
    rescue JSON::ParserError
      false
    end
  end

  def parse_json(path, **options)
    JSON.parse(read_file(path, **options))
  end

  def path_for(project)
    @projects ||= parse_json("config/projects.json")
    @projects[project]["path"]
  end

  def build_command_for(project)
    @projects ||= parse_json("config/projects.json")
    @projects[project]["build"] || "SKIP_DEPENDENCY_CHECKER=true ember build -prod"
  end

  def here(**options)
    in_dir(".", **options) { yield }
  end

  def in_app(**options)
    in_dir(path_for("app"), expand: false, **options) { yield }
  end

  def in_ember(**options)
    in_dir(path_for("ember"), expand: false, **options) { yield }
  end

  def in_glimmer(**options)
    in_dir(path_for("glimmer"), expand: false, **options) { yield }
  end

  def in_tmpdir(**options)
    Dir.mktmpdir { |tmpdir| in_dir(tmpdir, expand: false, **options) { yield } }
  end

  def in_dir(path, expand: true, silent: false)
    path = full_path(path) if expand

    unless silent
      puts "Changing CWD to #{path}".light_blue
      puts
    end

    result = Dir.chdir(path) { yield }

    unless silent
      puts
      puts "Exiting #{path}".light_blue
      puts
    end

    result
  end

  def install_node_modules(**options)
    if exists?("yarn.lock", expand: false)
      run("rm -rf node_modules", **options) &&
      run("yarn install", **options)
    else
      run "npm install", **options
    end
  end

  def install_bower_components
    if exists?("bower.json", expand: false)
      run "bower install"
    else
      true
    end
  end

  def experiments
    @experiments ||= parse_json("config/experiments.json")
  end

  def experiment_config(name)
    experiments.find { |experiment| experiment["name"] === name }
  end

  def each_experiment
    experiments.each { |experiment| yield experiment }
  end

  def custom_ember?(experiment = nil)
    if experiment
      experiment["ember"]
    else
      experiments.any? { |e| e["ember"] }
    end
  end

  def custom_glimmer?(experiment = nil)
    return false unless custom_ember?(experiment)

    if experiment
      experiment["glimmer"]
    else
      experiments.any? { |e| e["glimmer"] }
    end
  end

  def kill_puma!
    pid = read_file('tmp/puma.pid').strip.to_i

    puts
    puts "Shutting down puma...".yellow
    puts

    run "kill #{pid}", silent: true, allow_failure: true
    run "rm tmp/puma.pid", silent: true, allow_failure: true
  rescue Errno::ENOENT
  end
end

include Utils
