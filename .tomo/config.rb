plugin "git"
plugin "env"
plugin "bundler"
plugin "rails"
plugin "nodenv"
plugin "puma"
plugin "./plugins/bindrpz.rb"

host "afiq@113.23.254.70"

set application: "bindrpz"
set deploy_to: "/var/www/%{application}"
set git_url: "git@github.com:skecth/bindrpz.git"
set git_branch: "main"
set git_exclusions: %w[
  .tomo/
  spec/
  test/
]
set env_vars: {
  BUILD_AT: Time.now.to_i,
  RACK_ENV: "production",
  RAILS_ENV: "production",
  RAILS_LOG_TO_STDOUT: "1",
  RAILS_SERVE_STATIC_FILES: "1",
  BOOTSNAP_CACHE_DIR: "tmp/bootsnap-cache",
}
set linked_dirs: %w[
  .yarn/cache
  log
  node_modules
  public/assets
  tmp/cache
  tmp/pids
  tmp/sockets
  app/assets/builds
]

set linked_files: %w[
  config/database.yml
]

setup do
  run "env:setup"
  run "core:setup_directories"
  run "git:clone"
  run "git:create_release"
  run "core:symlink_shared"
  run "bundler:upgrade_bundler"
  run "bundler:config"
  run "bundler:install"
  run "puma:setup_systemd"
end

deploy do
  run "env:update"
  run "git:create_release"
  run "core:symlink_shared"
  run "core:write_release_json"
  run "bundler:install"
  run "rails:db_create"
  run "rails:db_migrate"
  run "rails:assets_precompile"
  run "core:symlink_current"
  run "puma:restart"
  run "puma:check_active"
  run "core:clean_releases"
  run "bundler:clean"
  run "core:log_revision"
end
