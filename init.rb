require 'redmine'

# patches to the redmine core
require 'dispatcher'
require 'short_mail_subject_mailer_patch'

Dispatcher.to_prepare do
  Mailer.send(:include, ShortMailSubjectMailerPatch)
end

Redmine::Plugin.register :redmine_short_mail_subject do
  name 'Short Mail Subject plugin'
  author 'Junya Ogura'
  description 'This plugin modify subject of notification mail more short'
  version '0.0.1'
end
