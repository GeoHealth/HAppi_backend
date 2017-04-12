class ApplicationMailer < ActionMailer::Base
  default from: 'postmaster@mail.happi-doctor.be'
  layout 'mailer'
end
