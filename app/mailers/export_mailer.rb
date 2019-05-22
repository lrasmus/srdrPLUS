class ExportMailer < ApplicationMailer
  default from: 'support@srdrPLUS.com'

  def notify_simple_export_completion(exported_file_id)
    @exported_file = ExportedFile.find exported_file_id
    @user    = @exported_file.user
    @project = @exported_file.project
    mail(to: @user.email, subject: 'You have a notification from srdrPLUS')
  end
end
