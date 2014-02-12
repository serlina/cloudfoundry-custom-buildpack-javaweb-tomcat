require 'yaml'

class Global

  attr_reader :build_path, :cache_path

  def initialize(build_path, cache_path)
    @build_path = build_path
    @cache_path = cache_path
  end

  def url_yml_path
      @url_yml_path ||= File.join(File.dirname(File.dirname(__FILE__)), 'config', 'url.yml')
  end

  def dependency_yml_path
    @dependency_yml_path ||= File.join(build_path, 'config', 'dependency.yml')
  end

  def dependency_yml
    if File.exist? dependency_yml_path
      @dependency_yml ||= YAML.load_file(dependency_yml_path)
    else
      return nil
    end
  end

  def url_yml
    @url_yml ||= YAML.load_file(url_yml_path)
  end

  def remote_jdk_url
    base = url_yml['base']
    if dependency_yml and not dependency_yml['jdk'].nil?
      File.join(base, dependency_yml['jdk'])
    else
      File.join(base, url_yml['default']['jdk'])
    end
  end

  def remote_tomcat_url
    base = url_yml['base']
    if dependency_yml and not dependency_yml['tomcat'].nil?
      File.join(base, dependency_yml['tomcat'])
    else
      File.join(base, url_yml['default']['tomcat'])
    end
  end

  def tmp_jdk_path
    File.join(cache_path, 'jdk.tar.gz')
  end

  def tmp_tomcat_path
    File.join(cache_path, 'tomcat.tar.gz')
  end

  def target_jdk_tarball
    File.join(jdk_dir, 'jdk.tar.gz')
  end

  def target_tomcat_tarball
    File.join(tomcat_dir, 'tomcat.tar.gz')
  end

  def jdk_dir
    File.join(build_path, '.jdk')
  end

  def tomcat_dir
    File.join(build_path, '.tomcat')
  end

end