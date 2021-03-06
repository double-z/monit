# reload: Reload monit so it notices the new service.  :delayed (default) or :immediately.
# action: :enable To create the monitoring config (default), or :disable to remove it.
# variables: Hash of instance variables to pass to the ERB template
# template_cookbook: the cookbook in which the configuration resides
# template_source: filename of the ERB configuration template, defaults to <LWRP Name>.conf.erb
define :monitrc, :action => :enable, :reload => :delayed, :variables => {}, :template_cookbook => "monit", :template_source => nil do
  params[:template_source] ||= "#{params[:name]}.conf.erb"

  if node['monit']['init_style'] == 'runit'
#    include_recipe "runit"
    include_recipe "monit::runit"
  end

  service_to_notify = case node['monit']['init_style']
                      when "runit"
                        "runit_service[monit]"
                      else
                        "service[monit]"
                      end

  if params[:action] == :enable
    template "/etc/monit/conf.d/#{params[:name]}.conf" do
      owner "root"
      group "root"
      mode 0644
      source params[:template_source]
      cookbook params[:template_cookbook]
      variables params[:variables]
      notifies :restart, service_to_notify, params[:reload]
#      notifies :restart, "service[monit]", params[:reload]
#      	notifies :restart, "runit_service[monit]", params[:reload]
      action :create
    end
  else
    template "/etc/monit/conf.d/#{params[:name]}.conf" do
      action :delete
      notifies :restart, service_to_notify, params[:reload]
#      notifies :restart, "service[monit]", params[:reload]
#      	notifies :restart, "runit_service[monit]", params[:reload]
    end
  end
end
