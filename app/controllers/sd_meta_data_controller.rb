class SdMetaDataController < ApplicationController
  around_action :wrap_in_transaction

  def mapping_update
    key_questions = mapping_params[:key_questions] || {}
    SdKeyQuestionsProject.
      where(sd_key_question_id: SdMetaDatum.
      find(params[:sd_meta_datum_id]).
      sd_key_questions).
      destroy_all

    key_questions.keys.each do |kq_project_id|
      key_questions[kq_project_id].each do |sd_kq_id|
        SdKeyQuestionsProject.create(key_questions_project_id: kq_project_id, sd_key_question_id: sd_kq_id)
      end
    end
    head :no_content
  end

  def section_update
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    sd_meta_datum.update(section_params)
    render json: { status: section_params.values.first }, status: 200
  end

  def destroy
    sd_meta_datum =  SdMetaDatum.find(params[:id]).destroy
    if sd_meta_datum.destroyed?
      flash[:notice] = "Succesfully deleted Sd Meta Datum ID: #{sd_meta_datum.id}"
      redirect_to sd_meta_data_path
      flash[:alert] = "Error deleting Sd Meta Datum ID: #{sd_meta_datum.id}"
      redirect_to sd_meta_data_path
    end
  end

  def create
    @sd_meta_datum = SdMetaDatum.create(project_id: params[:project_id])
    @sd_meta_datum.create_fuzzy_matches
    flash[:notice] = "Succesfully created Sd Meta Datum ID: #{@sd_meta_datum.id} for Project ID: #{@sd_meta_datum.project_id}"
    redirect_to edit_sd_meta_datum_path(@sd_meta_datum.id)
  end

  def edit
    @panel_number = params[:panel_number].try(:to_i) || 0
    @sd_meta_datum = SdMetaDatum.find(params[:id])
    @project = SRDR::Project.find(@sd_meta_datum.project_id)
    @url = sd_meta_datum_path(@sd_meta_datum)
  end

  def update
    @sd_meta_datum = SdMetaDatum.find(params[:id])
    @project = SRDR::Project.find(@sd_meta_datum.project_id)
    @url = sd_meta_datum_path(@sd_meta_datum)
    sd_meta_datum = SdMetaDatum.find(params[:id])
    update = sd_meta_datum.update(sd_meta_datum_params)
  ensure
    if request.xhr?
      head :no_content
    else
      if update
        redirect_to sd_meta_data_path
      else
        render :edit
      end
    end
  end

  def index
    @projects = SRDR::Project.all
    @sd_meta_data = SdMetaDatum.all
  end

  private

    def wrap_in_transaction
      ActiveRecord::Base.transaction do
        begin
          ActiveRecord::Base.connection.execute('SET foreign_key_checks = 0;')
          yield
        ensure
          ActiveRecord::Base.connection.execute('SET foreign_key_checks = 1;')
        end
      end
    end

    def mapping_params
      params.
        require(:sd_meta_datum).
          permit(:_, key_questions: { })
    end

    def section_params
      params.
        require(:sd_meta_datum).
          permit(
            :section_flag_0,
            :section_flag_1,
            :section_flag_2,
            :section_flag_3,
            :section_flag_4,
            :section_flag_5,
            )
    end

    def sd_meta_datum_params
      params.
        require(:sd_meta_datum).
          permit(
            :project_id,
            :report_title,
            { funding_source_ids: [] },
            :date_of_last_search,
            :date_of_publication_full_report,
            :state,
            :stakeholder_involvement_extent,
            :authors_conflict_of_interest_of_full_report,
            :stakeholders_conflict_of_interest,
            :prototcol_link,
            :full_report_link,
            :structured_abstract_link,
            :key_messages_link,
            :abstract_summary_link,
            :evidence_summary_link,
            :evs_introduction_link,
            :evs_methods_link,
            :evs_results_link,
            :evs_discussion_link,
            :evs_conclusions_link,
            :evs_tables_figures_link,
            { sd_journal_article_urls_attributes: [:id, :name, :_destroy, :id] },
            { sd_other_items_attributes: [:id, :name, :url, :_destroy, :id] },
            :disposition_of_comments_link,
            :srdr_data_link,
            :most_previous_version_srdr_link,
            :most_previous_version_full_report_link,
            :overall_purpose_of_review,
            :type_of_review,
            :level_of_analysis,
            { sd_analytic_frameworks_attributes: [:id, :name, :_destroy, :id, pictures: []] },
            { sd_key_questions_attributes: [:key_question_id, { key_question_type_ids: [] }, :name, :_destroy, :id, { sd_key_questions_key_question_type_ids: [] }] },
            { sd_key_question_ids: [] },
            { sd_picods_attributes: [:sd_key_questions, :p_type, :name, :_destroy, :id] },
            { sd_search_strategies_attributes: [:sd_search_database_id, :date_of_search, :search_limits, :search_terms, :_destroy, :id] },
            { sd_grey_literature_searches_attributes: [:name, :_destroy, :id] },
            { sd_prisma_flows_attributes: [:name, :_destroy, :id, pictures: []] },
            { sd_summary_of_evidences_attributes: [:sd_key_question, :soe_type, :name, :_destroy, :id] }
          )
    end
end
