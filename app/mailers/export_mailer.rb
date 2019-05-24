class ExportMailer < ApplicationMailer
  default from: 'support@srdrPLUS.com'

  def notify_simple_export_completion(exported_file_id)
    @exported_file = ExportedFile.find exported_file_id
    @user    = @exported_file.user
    @project = @exported_file.project
    mail(to: @user.email, subject: 'You have a notification from srdrPLUS')
  end

  def notify_gsheets_export_completion(user_id, project_id, google_link)
    @user    = User.find user_id
    @project = Project.find project_id
    @google_link = google_link
    mail(to: @user.email, subject: 'You have a notification from srdrPLUS')
  end
end
