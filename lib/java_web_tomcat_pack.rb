#! /usr/bin/ruby -w
# coding: utf-8
# author: Ulric Qin
# mail: qinxiaohui@xiaomi.com

require 'java_pack'
require 'system_util'
require 'fetcher'

class JavaWebTomcatPack < JavaPack

  def initialize(global)
    super(global)
  end

  def compile
    Fetcher.install_jdk(global)
    Fetcher.install_tomcat(global)
    copy_webapp_to_tomcat
    move_tomcat_to_root
    copy_resources
    setup_profiled
  end

  def copy_webapp_to_tomcat
    SystemUtil.run_with_err_output("mkdir -p #{global.tomcat_dir}/webapps/ROOT && mv #{global.build_path}/* #{global.tomcat_dir}/webapps/ROOT")
  end

  def move_tomcat_to_root
    SystemUtil.run_with_err_output("mv #{global.tomcat_dir}/* #{global.build_path} && rm -rf #{global.tomcat_dir}")
  end

  def copy_resources
    # Configure server.xml with variable HTTP port
    SystemUtil.run_with_err_output("cp -r #{File.expand_path('../../resources/tomcat', __FILE__)}/* #{global.build_path}")
  end

  def java_opts
    # Don't override Tomcat's temp dir setting
    opts = super.merge({ '-Dhttp.port=' => '$PORT' })
    opts.delete('-Djava.io.tmpdir=')
    opts
  end

end