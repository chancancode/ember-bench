require "bundler/setup"
require "rack"
require "open3"
require_relative "utils"

EXPERIMENTS = parse_json("config/experiments.json")

class Reporter
  def call(env)
    req = Rack::Request.new(env)

    control = req.params["control"]
    experiment = req.params["experiment"]

    header = { "Content-Type" => "text/html" }

    download = req.params["mode"] == "save"

    if download
      header["Content-Disposition"] = 'attachment; filename="report.html"'
    end

    if control && experiment
      [200, header, [report(control, experiment, download)]]
    else
      [200, header, [index(control, experiment)]]
    end
  end

  private

  def index(control, experiment)
    <<-HTML
      <form action="/">
        <label for="control">Control:</label>
        <select name="control">
          #{
            options = EXPERIMENTS.map do |item|
              name = item["name"]
              selected = (name == control ? " selected" : "")
              %(<option value="#{name}"#{selected}>#{name}</option>)
            end

            options.join("\n")
          }
        </select>

        <label for="experiment">Experiment:</label>
        <select name="experiment">
          #{
            options = EXPERIMENTS.map do |item|
              name = item["name"]
              selected = (name == experiment ? " selected" : "")
              %(<option value="#{name}"#{selected}>#{name}</option>)
            end

            options.join("\n")
          }
        </select>

        <button name="mode" value="view">View</button>
        <button name="mode" value="save">Save</button>
      </form>
    HTML
  end

  def report(control, experiment, download)
    <<-HTML
      #{
        if download
          "<h1>#{control} vs #{experiment}"
        else
          index(control, experiment)
        end
      }

      <hr>

      <h2>Config</h2>

      <h3>Control: #{control}</h3>

      <pre><code>#{JSON.pretty_generate(experiment_cofig(control))}</code></pre>

      <h3>Experiment: #{experiment}</h3>

      <pre><code>#{JSON.pretty_generate(experiment_cofig(experiment))}</code></pre>

      <hr>

      <h2>Total Duration</h2>

      #{plot(control, experiment, "duration")}

      <hr>

      <h2>JS Time</h2>

      #{plot(control, experiment, "js")}
    HTML
  end

  def plot(control, experiment, stat)
    control_data = parse_json("results/#{control}.json")
    experiment_data = parse_json("results/#{experiment}.json")

    csv = "ms,set\n"

    control_data["samples"].each do |sample|
      csv << "#{sample[stat] /1000.0},CONTROL: #{control}\n"
    end

    experiment_data["samples"].each do |sample|
      csv << "#{sample[stat] /1000.0},EXPERIMENT: #{experiment}\n"
    end

    in_tmpdir(silent: true) do
      report, _ = Open3.capture2(full_path("bin/plot"), stdin_data: csv)
      boxplot = read_file("boxplot.svg", expand: false)
      histogram = read_file("histogram.svg", expand: false)

      <<-HTML
        <h3>Report</h3>

        <pre><code>#{report}</code></pre>

        <h3>Boxplot</h3>

        #{clean_svg("boxplot" + "-" + stat, boxplot)}

        <h3>Histogram</h3>

        #{clean_svg("histogram" + "-" + stat, histogram)}
      HTML
    end
  end

  def clean_svg(name, svg)
    svg.gsub('<?xml version="1.0" encoding="UTF-8"?>', "")
       .gsub(/glyph(\d+)/, "#{name}-glyph\\1")
  end
end

run Reporter.new
