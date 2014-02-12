require 'net/http'
require 'uri'
require 'yaml'
require 'fileutils'
require 'system_util'

class Fetcher

  def self.install_jdk(global)
    puts 'Installing JDK...'
    tmp_jdk = fetch(global.tmp_jdk_path, global.remote_jdk_url)

    dir = File.dirname(global.target_jdk_tarball)
    FileUtils.mkdir_p(dir)
    FileUtils.mv(tmp_jdk, global.target_jdk_tarball)

    puts "Unpacking JDK to #{global.jdk_dir}..."
    tar_output = SystemUtil.run_with_err_output "tar pxzf #{global.target_jdk_tarball} -C #{global.jdk_dir}"

    FileUtils.rm_rf global.target_jdk_tarball

    unless File.exists?("#{global.jdk_dir}/bin/java")
      puts 'Unable to retrieve the JDK'
      puts tar_output
      exit 1
    end
  end

  def self.install_tomcat(global)
    puts 'Installing Tomcat...'

    tmp_tomcat = fetch(global.tmp_tomcat_path, global.remote_tomcat_url)
    dir = File.dirname(global.target_tomcat_tarball)
    FileUtils.mkdir_p(dir)
    FileUtils.mv(tmp_tomcat, global.target_tomcat_tarball)

    puts "Unpacking Tomcat to #{global.tomcat_dir}..."
    tar_output = SystemUtil.run_with_err_output "tar pxzf #{global.target_tomcat_tarball} -C #{global.tomcat_dir}"

    FileUtils.rm_rf global.target_tomcat_tarball

    unless File.exist?("#{global.tomcat_dir}/bin/catalina.sh")
      puts 'Unable to retrieve the tomcat'
      puts tar_output
      exit 1
    end

    remove_tomcat_files(global.tomcat_dir)

  end

  def self.remove_tomcat_files(tomcat_dir)
    %w[NOTICE RELEASE-NOTES RUNNING.txt LICENSE webapps/. work/. logs].each do |file|
      FileUtils.rm_rf("#{tomcat_dir}/#{file}")
    end
  end

  def self.fetch(file_path, url)
    puts "Downloading #{file_path} from #{url} ... "

    dir = File.dirname(file_path)
    FileUtils.mkdir_p(dir)
    File.open(file_path, 'w') do |tf|
      begin
        Net::HTTP.get_response(URI.parse(url)) do |response|
          unless response.is_a?(Net::HTTPSuccess)
            puts 'Could not fetch file (%s): %s/%s' % [file_path, response.code, response.body]
            return
          end

          response.read_body do |segment|
            tf.write(segment)
          end
        end
      ensure
        tf.close
      end
    end
    file_path
  end

end