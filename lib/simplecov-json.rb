require 'simplecov'
require 'json'
require 'simplecov-json/version'

class SimpleCov::Formatter::JSONFormatter
  @pretty = false

  def self.configure &block
    yield self if block_given?
  end

  def self.pretty_format pretty_format = nil
    @pretty = pretty_format if pretty_format
    @pretty
  end

  def pretty_format?
    self.class.pretty_format
  end

  def format(result)
    data = {}
    data[:type] = 'simplecov-json'
    data[:version] = VERSION
    data[:timestamp] = result.created_at.to_i
    data[:command_name] = result.command_name
    data[:files] = []

    result.files.each do |sourceFile|
      next unless result.filenames.include? sourceFile.filename

      data[:files] << {
        filename: sourceFile.filename.gsub(/^#{SimpleCov.root}/,''),
        src: File.exist?(sourceFile.filename) ? File.read(sourceFile.filename) : '',
        covered_percent: sourceFile.covered_percent,
        coverage: sourceFile.coverage,
        covered_strength: sourceFile.covered_strength.nan? ? 0.0 : sourceFile.covered_strength,
        covered_lines: sourceFile.covered_lines.count,
        lines_of_code: sourceFile.lines_of_code,
      }
    end

    data[:metrics] = {
      covered_percent: result.covered_percent,
      covered_strength: result.covered_strength.nan? ? 0.0 : result.covered_strength,
      covered_lines: result.covered_lines,
      total_lines: result.total_lines
    }
  
    json = (pretty_format? ? JSON.pretty_generate(data) : data.to_json)
    
    File.open(output_filepath, "w+") do |file|
      file.puts json
    end
    
    puts output_message(result)
    
    json
  end
  
  def output_filename
    'coverage.json'
  end
  
  def output_filepath
    File.join(output_path, output_filename)
  end
  
  def output_message(result)
    "Coverage report generated for #{result.command_name} to #{output_filepath}. #{result.covered_lines} / #{result.total_lines} LOC (#{result.covered_percent.round(2)}%) covered."
  end
  
private
  
  def output_path
    SimpleCov.coverage_path
  end
  
end
