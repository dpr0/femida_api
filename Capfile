# frozen_string_literal: true

require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/rbenv'
require 'capistrano/puma'
require 'capistrano/sidekiq'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git
install_plugin Capistrano::Puma
install_plugin Capistrano::Sidekiq
install_plugin Capistrano::Sidekiq::Systemd

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
