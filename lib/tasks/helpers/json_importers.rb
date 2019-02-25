module JsonImporters
  class ProjectImporter
    def initialize(logger)
      # we need to store stuff like the project, so an instance variable maybe?
      @p = Project.new
      @logger = logger

      @id_map = {}

      @id_map['color'] = {}
      @id_map['comparison'] = {}
      @id_map['cp'] = {}
      @id_map['efps'] = {}
      @id_map['eefps'] = {}
      @id_map['eefpst1'] = {}
      @id_map['kqp'] = {}
      @id_map['population'] = {}
      @id_map['qrcf'] = {}
      @id_map['question'] = {}
      @id_map['role'] = {}
      @id_map['t1'] = {}
      @id_map['tp'] = {}
      @id_map['user'] = {}

      @dedup_map = {}
      @dedup_map['efps'] = {}
      @dedup_map['question'] = {}

      @t1_link_dict = {}
      @eefps_t1_link_dict = {}
      @question_dependency_dict = {}

      @section_position_tuples = []

      @question_position_counter_dict = {}
      @question_position_tuples_dict = {}
    end

    def import_project(phash)
      Project.transaction do

        ## PROJECT INFO
        @p.update!({
                       name: phash['name'],
                       description: phash['description'],
                       attribution: phash['attribution'],
                       methodology_description: phash['methodology_description'],
                       prospero: phash['prospero'],
                       doi: phash['doi'],
                       notes: phash['notes'],
                       funding_source: phash['funding_source']})

        ## KEY QUESTIONS
        phash['key_questions']&.each(&method(:import_key_question))

        ## USERS
        phash['users']&.each(&method(:import_user))

        ## CITATIONS
        phash['citations']&.each(&method(:import_citation))

        ## TASKS
        phash['tasks']&.values&.each(&method(:import_task))

        ## EFPSs
        position_counter = 0
        phash['extraction_forms']&.values&.each do |efhash|
          efhash['sections']&.each do |sid, shash|
            linked_shash = nil
            if shash['link_to_type1'].present?
              linked_shash = efhash['sections']['link_to_type1']
            end
            import_efps(sid, shash, linked_shash, position_counter)
          end
          position_counter += (0 || efhash['sections'].length)
        end

        # does this work? TEST!
        @question_position_tuples_dict.values&.each do |q_tuples|
          q_tuples.sort { |tuple| tuple[0] }
          q_tuples.each.with_index do |tuple, index|
            q = tuple[1]
            q.ordering.position = index + 1
          end
        end

        @question_dependency_dict.each do |question_id, dependendable_id|

        end

        # does this work? TEST!
        @t1_link_dict.each do |t2_efps_id, t1_efps_source_id|
          ExtractionFormsProjectsSection.find(t2_efps_id).update!(link_to_type1: @id_map['efps'][t1_efps_source_id])
        end

        # does this work? TEST!
        @section_position_tuples.sort { |tuple| tuple[0] }
        @section_position_tuples.each.with_index do |tuple, index|
          efps = tuple[1]
          efps.ordering.position = index + 1
        end

        ## EXTRACTIONS
        phash['extractions']&.values&.each do |ehash|
          import_extraction(ehash)
        end

      end
      @p.id
    end

    def import_user(uid, uhash)
      # is this enough to identify a user or should we check profile as well??
      u = User.find_by({id: uid, email: uhash['email']})

      if u.nil?
        temp_password = "Please_Update_Your_Password"
        u = User.create!(email: uhash['email'], password: temp_password)
        profile_hash = uhash['profile']

        o = Organization.find_or_create_by! name: profile_hash['organization']['name']

        profile = Profile.find_or_create_by! user:         u,
                                             username:     profile_hash['username'],
                                             first_name:   profile_hash['first_name'],
                                             middle_name:  profile_hash['middle_name'],
                                             last_name:    profile_hash['last_name'],
                                             time_zone:    profile_hash['time_zone'],
                                             organization: o

        profile_hash['degrees']&.values&.each do |dhash|
          d = Degree.find_or_create_by! name: dhash['name']
          DegreesProfile.find_or_create_by! degree: d,
                                            profile: profile
        end
      end

      @id_map['user'][uid.to_i] = u

      pu = ProjectsUser.find_or_create_by!({project: @p, user: u})

      uhash['roles']&.each do |rid, rhash|
        r = find_role(rid, rhash['name'])
        ProjectsUsersRole.find_or_create_by(projects_user: pu, role: r)
      end

      uhash['term_groups']&.values&.each do |tghash|
        tg = TermGroup.find_or_create_by!(name: tghash['name'])
        c = find_color(tghash['color']['id'], tghash['color']['name'])
        tgc = TermGroupsColor.find_or_create_by!({term_group: tg, color: c})
        putgc = ProjectsUsersTermGroupsColor.find_or_create_by!(projects_user: pu, term_groups_color: tgc)

        tghash['terms']&.values&.each do |thash|
          t = Term.find_or_create_by!(name: thash['name'])
          ProjectsUsersTermGroupsColorsTerm.find_or_create_by!(projects_users_term_groups_color: putgc, term: t)
        end
      end
    end

    def import_key_question(kqpid, kqhash)
      kqp = @id_map['kqp'][kqpid]
      if kqp.present? then return kqp end

      kq = KeyQuestion.find_or_create_by!(name: kqhash['name'])
      kqp = KeyQuestionsProject.find_or_create_by(project: @p, key_question: kq)
      @id_map['kqp'][kqpid] = kqp
    end

    def find_role(rid, role_name)
      #check dictionary first
      r =  @id_map['role'][rid.to_i]
      if r.present? then return r end

      #then try to find it by name
      r = Role.find_by(name: role_name)
      if r.present?
        @id_map['role'][rid.to_i] = r
        return r
      end

      #if can't find, use Contributor
      r = Role.find_by(name: 'Contributor')
      @logger.warning "#{Time.now.to_s} - Could not find role with name '" +  role_name + "' for user: '" + u.profile.username + "', used 'Contributor' instead"
      @id_map['role'][rid.to_i] = r
      return r
    end

    def find_color(cid, color_name)
      #this is probably a bad way to find the color
      c = @id_map['color'][cid]
      if c.present? then return c end

      c = Color.find_by(name: color_name)
      if c.present?
        @id_map['color'][cid] = c
        return c
      end

      ## try to use different colors
      c = Color.where.not( id: @id_map['color'].values.map {|c| c.id} ).first
      @logger.warning "#{Time.now.to_s} - Could not find color with name '" + color_name + "', used '" + c.name + "' instead"
      @id_map['color'][cid] = c
      return c
    end

    def find_projects_user(uid)
      u = @id_map['user'][uid]
      if u.present?
        return ProjectsUser.find_by(project: @p, user: u)
      end
      return nil
    end

    def find_projects_users_role(uid, rid)
      u = @id_map['user'][uid]
      r = @id_map['role'][rid]

      if u.present? and r.present?
        pu = ProjectsUser.find_by(project: @p, user: u)
        return ProjectsUsersRole.find_by!(projects_user: pu, role: r)
      end
      return nil
    end

    def import_citation(cpid, chash)
      if @id_map['cp'][cpid].present? then return @id_map['cp'][cpid] end

      j = Journal.find_or_create_by!(name: chash['journal']['name'])

      c = Citation.create!({name: chash['name'],
                            abstract: chash['abstract'],
                            refman: chash['refman'],
                            pmid: chash['pmid'],
                            journal: j})

      chash['keywords']&.values&.each do |kwhash|
        kw = Keyword.find_or_create_by!(name: kwhash['name'])
        c.keywords << kw
      end

      chash['authors']&.values&.each do |ahash|
        a = Author.find_or_create_by!(name: ahash['name'])
        c.authors << a
      end

      cp = CitationsProject.find_or_create_by! project: @p, citation: c

      chash['labels']&.values&.each do |lhash|
        pur = find_projects_users_role(lhash['labeler_user_id'], lhash['labeler_role_id'])
        lt = LabelType.find_by(name: lhash['label_type']['name'])
        l = Label.create!(citations_project: cp, projects_users_role: pur, label_type: lt)

        lhash['reasons']&.values&.each do |rhash|
          r = Reason.find_or_create_by!(name: rhash['name'])
          LabelsReason.find_or_create_by!(projects_users_role: pur, reason: r, label: l)
        end
      end

      chash['tags']&.values&.each do |thash|
        pur = find_projects_users_role(thash['creator_user_id'], thash['creator_role_id'])
        t = Tag.find_or_create_by!(name: thash['name'])
        Tagging.create!({taggable_type: 'CitationsProject',
                         taggable_id: cp.id,
                         projects_users_role: pur,
                         tag: t})
      end

      chash['notes']&.values&.each do |nhash|
        pur = find_projects_users_role(nhash['creator_user_id'], nhash['creator_role_id'])
        Note.create!({projects_users_role: pur,
                      notable_type: 'CitationsProject',
                      notable_id: cp.id,
                      value: nhash['value']})
      end
      cp = CitationsProject.find_or_create_by!(citation: c, project: @p)
      @id_map['cp'][cpid.to_i] = cp
    end

    def import_task(thash)
      tt = TaskType.find_by(name: thash['task_type']['name'])
      if tt.nil?
        tt = TaskType.first
        logger.warning "#{Time.now.to_s} - Could not find task_type with name '" + thash['task_type']['name'] + ", used '" + tt.name + "' instead."
      end
      na = thash['num_assigned']

      t = Task.create!(project: @p, task_type: tt, num_assigned: na)

      thash['assignments']&.values&.each do |ahash|
        pur = find_projects_users_role(ahash['assignee_user_id'], ahash['assignee_role_id'])

        t.assignments << Assignment.create!({projects_users_role: pur,
                                             done_so_far: ahash['dones_so_far'],
                                             date_due: ahash['date_due'],
                                             done: ahash['done']})
      end
    end

    def get_efps_dedup_key(shash, linked_shash)
      efps_type_name = shash['extraction_forms_projects_section_type']['name']
      section_name = shash['section']['name']
      if efps_type_name == "Type 1" and shash['type1s'].present?
        return "<<<#{section_name}&&#{efps_type_name}&&#{(shash['type1s']&.values&.map {|t1hash| t1hash['name']}).sort.join("||")}>>>"
      elsif efps_type_name == "Type 2" and linked_shash.present? and linked_shash['type1s'].present?
        return "<<<#{section_name}&&#{efps_type_name}&&#{(linked_shash&['type1s']&.values&.map {|t1hash| t1hash['name']}).sort.join("||")}>>>"
      elsif efps_type_name == "Results"
        ## there should only ever be one results section?
        return "<<<#{efps_type_name}>>>"
      else
        return "<<<#{section_name}&&#{efps_type_name}>>>"
      end
    end

    def figure_out_efps_type(shash)
      if shash['questions'] or shash['link_to_type1']
        return ExtractionFormsProjectsSectionType.find_by name: 'Type 2'
      elsif shash['type1s']
        return ExtractionFormsProjectsSectionType.find_by name: 'Type 1'
      else
        return ExtractionFormsProjectsSectionType.find_by name: 'Results'
      end
    end

    def import_efps(sid, shash, linked_shash, position_counter)
      efps = @id_map['efps'][sid]
      if efps.present? then return efps end

      #if this is a duplicate section, we just want to return the original
      dedup_key = get_efps_dedup_key shash, linked_shash
      efps = @dedup_map['efps'][dedup_key]
      if efps.present?
        @id_map['efps'][sid] = efps
        return efps
      end

      #do we want to create sections that does not exist? -Birol
      s = Section.find_or_create_by! name: shash['section']['name']
      efps_type = ExtractionFormsProjectsSectionType.find_by! name: shash['extraction_forms_projects_section_type']['name']

      if efps_type.nil?
        efps_type = figure_out_efps_type shash
        logger.warning "#{Time.now.to_s} - Could not find extraction_forms_projects_section_type with name '" +  shash['extraction_forms_projects_section_type']['name'] + ", used '" + efps_type.name + "' instead."
      end

      if efps.nil?
        efps = ExtractionFormsProjectsSection.find_or_create_by! extraction_forms_project: @p.extraction_forms_projects.first,
                                                                 extraction_forms_projects_section_type: efps_type,
                                                                 section: s
        @section_position_tuples << [shash['position'].to_i + position_counter, efps]

        link_to_type1 = shash['link_to_type1']
        if link_to_type1.present?
          @t1_link_dict[efps.id] = link_to_type1
        end

        shash['type1s']&.each do |t1id, t1hash|
          t1 = Type1.find_or_create_by!(name: t1hash['name'], description: t1hash['description'])
          efps.type1s << t1
          @id_map['t1'][t1id] = t1
        end

        #create efps first
        efpsohash = shash['extraction_forms_projects_section_option']
        if efpsohash.present?
          ExtractionFormsProjectsSectionOption.create! extraction_forms_projects_section: efps,
                                                       by_type1: efpsohash['by_type1'],
                                                       include_total: efpsohash['include_total']
        end
      end

      @question_position_counter_dict[efps.id] ||= 0
      @question_position_tuples_dict[efps.id] ||= []
      @dedup_map['question'][efps.id] ||= {}

      shash['questions']&.each do |qid, qhash|
        import_question(efps, qid, qhash)
      end
      @question_position_counter_dict[efps.id] += (shash['questions'] || []).length

      @id_map['efps'][sid] = efps
      @dedup_map['efps'] = efps
    end

    def get_question_dedup_key(qhash)
      q_dedup_key = "q: <<<" + qhash['name'].to_s + ">>> "
      qhash['key_questions']&.each do |kqid, kqhash|
        q_dedup_key += "kq: <<<" + kqhash['name'].to_s + ">>> "
      end
      qhash['question_rows']&.values&.each_with_index do |qrhash, ri|
        q_dedup_key += "qr: <<<" + qrhash['name'].to_s + ">>> "
        qrhash['question_row_columns']&.values&.each_with_index do |qrchash, ci|
          q_dedup_key += "qrc: <<<" + qrchash['name'].to_s + ">>> "
        end
      end
      return q_dedup_key
    end

    def import_question(efps, qid, qhash)
      if @id_map['question'][qid].present?
        return @id_map['eefpst1'][qid]
      end

      q_dedup_key = get_question_dedup_key(qhash)
      if @dedup_map['question'][efps.id][q_dedup_key].present?
        @id_map['question'][qid] = @dedup_map['question'][efps.id][q_dedup_key]
        return @dedup_map['question'][efps.id][q_dedup_key]
      end

      q = Question.create! extraction_forms_projects_section: efps,
                           name: qhash['name'],
                           description: qhash['description']

      qhash['dependencies']&.values&.each do |dephash|
        @question_dependency_dict[q.id] << dephash['dependable_id']
      end

      qhash['key_questions']&.each do |kqid|
        # maybe storing the kq id earlier and using that would be better? -Birol
        KeyQuestionsProjectsQuestion.find_or_create_by! key_question: @id_map['kqp'][kqid],
                                                        question: q
      end

      qhash['question_rows']&.values&.each_with_index do |qrhash, ri|

        if ri == 0
          qr = QuestionRow.find_by!(question: q)
        else
          qr = QuestionRow.new(question: q)
        end
        qr.update!(name: qrhash['name'])

        qrhash['question_row_columns']&.values&.each_with_index do |qrchash, ci|
          # maybe use find_by and raise an error if not found? -Birol

          qrc_type = QuestionRowColumnType.find_or_create_by! name: qrchash['question_row_column_type']['name']

          if ci == 0
            qrc = QuestionRowColumn.find_by! question_row: qr
          else
            qrc = QuestionRowColumn.new question_row: qr
          end

          qrc.update! question_row_column_type: qrc_type,
                      name: qrchash['name']

          qrc.question_row_columns_question_row_column_options.destroy_all
          # can i prevent creation of default options to begin with
          qrchash['question_row_columns_question_row_column_options']&.values&.each do |qrcqrcohash|
            qrcohash = qrcqrcohash['question_row_column_option']
            qrco = QuestionRowColumnOption.find_or_create_by! name: qrcohash['name']
            QuestionRowColumnsQuestionRowColumnOption.find_or_create_by! question_row_column: qrc,
                                                                         question_row_column_option: qrco,
                                                                         name: qrcqrcohash['name']

          end

          qrchash['question_row_column_fields']&.each do |qrcfid, qrcfhash|
            qrcf = QuestionRowColumnField.find_or_create_by!(question_row_column: qrc, name: qrcfhash['name'])
            @id_map['qrcf'][qrcfid] = qrcf
          end
        end
      end
      @dedup_map['question'][efps.id][q_dedup_key] = q
      @question_position_tuples_dict[efps.id] << [qhash['position'].to_i + @question_position_counter_dict[efps.id], q]
      @id_map['question'][qid] = q
    end

    def import_eefpst1(eefps, eefpst1hash)
      t1hash = eefpst1hash['type1']
      t1 = @id_map['t1'][t1hash['id']]

      if t1.nil?
        t1 = Type1.find_or_create_by!(name: t1hash['name'], description: t1hash['description'])
        @id_map['t1'][t1hash['id']] = t1
      end

      t1_type = nil
      if t1hash['type1_type'].present?
        t1_type = Type1Type.find_by(name: t1hash['type1_type']['name'])
        if t1_type.nil?
          t1_type = Type1Type.first
          logger.warning "#{Time.now.to_s} - Could not find type1_type with name #{t1hash['type1_type']['name']} , used #{t1_type.name} instead"
          ## maybe we should just use nil in this case
        end
      end

      eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1.find_or_create_by! extractions_extraction_forms_projects_section: eefps,
                                                                                   type1: t1

      ## I dont want to create duplicate t1 associations, so I use find_or_create_by!, then update!
      eefpst1.update! extractions_extraction_forms_projects_section: eefps,
                      type1: t1,
                      units: t1hash['units'],
                      type1_type: t1_type
      return eefpst1
    end

    def import_population

    end


    def import_extraction(ehash)
      cp = @id_map['cp'][ehash['citation_id']]
      pur = find_projects_users_role(ehash['extractor_user_id'], ehash['extractor_role_id'])

      e = Extraction.create! project: @p, projects_users_role: pur, citations_project: cp

      ehash['sections']&.each do |sid, shash|
        efps = @id_map['efps'][sid]

        # this has to be already there, because I'm counting on the callback and validations
        eefps = ExtractionsExtractionFormsProjectsSection.find_by! extraction: e,
                                                                   extraction_forms_projects_section: efps

        @id_map['eefps'][sid.to_i] = eefps

        #if shash['link_to_t1'].present?
        #  @eefps_t1_link_dict[eefps.id] = shash['link_to_t1']
        #end

        shash['extractions_extraction_forms_projects_sections_type1s']&.each do |eefpst1id, eefpst1hash|
          @id_map['eefpst1'][eefpst1id.to_i] = import_eefpst1(eefps, eefpst1hash)
        end
      end

      # here I use 2 loops where technically we should be able to get away with 1,
      # but it is hard to make sure no timepoint_id points to eefpst1 not yet created

      ehash['sections']&.each do |sid, shash|
        eefps = @id_map['eefps'][sid.to_i]

        shash['extractions_extraction_forms_projects_sections_type1s']&.each do |eefpst1id, eefpst1hash|
          eefpst1 = @id_map['eefpst1'][eefpst1id.to_i]

          eefpst1hash['populations']&.each do |popid, pophash|
            pop_name = PopulationName.find_or_create_by! name: pophash['population_name']['name']
            begin
              pop = ExtractionsExtractionFormsProjectsSectionsType1Row.find_or_create_by! extractions_extraction_forms_projects_sections_type1: eefpst1,
                                                                                          population_name: pop_name
            rescue => err
              byebug
            end

            @id_map['population'][popid.to_i] = pop

            pophash['timepoints']&.each do |tpid, tphash|
              tp_name = TimepointName.find_or_create_by! name: tphash['timepoint_name']['name'],
                                                         unit: tphash['timepoint_name']['unit']
              tp = ExtractionsExtractionFormsProjectsSectionsType1RowColumn.find_or_create_by! extractions_extraction_forms_projects_sections_type1_row: pop,
                                                                                               timepoint_name: tp_name
              @id_map['tp'][tpid.to_i] = tp
            end

            pophash['result_statistic_sections']&.values&.each do |rsshash|
              rss_type = ResultStatisticSectionType.find_or_create_by!({name: rsshash['result_statistic_section_type']['name']})

              rss = ResultStatisticSection.find_or_create_by! result_statistic_section_type: rss_type,
                                                              population: pop

              rsshash['comparisons']&.keys&.each do |compid|
                comp = Comparison.create!
                ComparisonsResultStatisticSection.create! result_statistic_section: rss, comparison: comp
                @id_map['comparison'][compid.to_i] = comp
              end

              ## comparisons are sometimes referring to other comparisons, so they all must be created beforehand

              rsshash['comparisons']&.each do |compid, comphash|
                comp = @id_map['comparison'][compid.to_i]
                comphash['comparate_groups']&.values&.each do |cghash|
                  cg = ComparateGroup.create! comparison: comp
                  cghash['comparates']&.values&.each do |cchash|
                    cehash = cchash['comparable_element']
                    if cehash['comparable_type'] == 'ExtractionsExtractionFormsProjectsSectionsType1'
                      ce = ComparableElement.create! comparable_type: 'ExtractionsExtractionFormsProjectsSectionsType1',
                                                     comparable_id: @id_map['eefpst1'][cehash['comparable_id']]&.id
                      Comparate.create! comparate_group: cg,
                                        comparable_element: ce

                    elsif cehash['comparable_type'] == 'ExtractionsExtractionFormsProjectsSectionsType1RowColumn'
                      ce = ComparableElement.create! comparable_type: 'ExtractionsExtractionFormsProjectsSectionsType1RowColumn',
                                                     comparable_id: @id_map['tp'][cehash['comparable_id']]&.id
                      Comparate.create! comparate_group: cg,
                                        comparable_element: ce
                    elsif cehash['comparable_type'] == 'Comparison'
                      ce = ComparableElement.create! comparable_type: 'Comparison',
                                                     comparable_id: @id_map['comparison'][cehash['comparable_id']]&.id
                      Comparate.create! comparate_group: cg,
                                        comparable_element: ce
                    else
                      logger.error "#{Time.now.to_s} - Unknown comparable_type"
                      ### YOU NEED TO ABORT COMPARISON CREATION
                    end
                  end
                end
              end

              rsshash['result_statistic_sections_measures']&.each do |rssmid, rssmhash|
                m = Measure.find_or_create_by!(name: rssmhash['measure']['name'])
                rssm = ResultStatisticSectionsMeasure.find_or_create_by!({result_statistic_section: rss,
                                                                          measure: m})

                if rssmhash['records'].present?
                  rssmhash['records']['tps_comparisons_rssms']&.values&.each do |tchash|
                    tcr = TpsComparisonsRssm.create!({timepoint: @id_map['tp'][tchash['timepoint_id']],
                                                      comparison: @id_map['comparison'][tchash['comparison_id']],
                                                      result_statistic_sections_measure: rssm})

                    Record.create!({recordable_type: 'TpsComparisonsRssm',
                                    recordable_id: tcr.id,
                                    name: tchash['record_name']})

                  end
                  rssmhash['records']['tps_arms_rssms']&.values&.each do |tahash|
                    tar = TpsArmsRssm.create!({timepoint: @id_map['tp'][tahash['timepoint_id']],
                                               extractions_extraction_forms_projects_sections_type1: @id_map['eefpst1'][tahash['arm_id']],
                                               result_statistic_sections_measure: rssm})

                    Record.create!({recordable_type: 'TpsArmsRssm',
                                    recordable_id: tar.id,
                                    name: tahash['record_name']})
                  end
                  rssmhash['records']['comparisons_arms_rssms']&.values&.each do |cahash|
                    car = ComparisonsArmsRssm.create!({comparison: @id_map['comparison'][cahash['comparison_id']],
                                                       extractions_extraction_forms_projects_sections_type1: @id_map['eefpst1'][cahash['arm_id']],
                                                       result_statistic_sections_measure: rssm})

                    Record.create!({recordable_type: 'ComparisonsArmsRssm',
                                    recordable_id: car.id,
                                    name: cahash['record_name']})
                  end
                  rssmhash['records']['wacs_bacs_rssms']&.values&.each do |wbhash|
                    tcr = WacsBacsRssm.create!({wac: @id_map['comparison'][wbhash['wac_id']],
                                                bac: @id_map['comparison'][wbhash['bac_id']],
                                                result_statistic_sections_measure: rssm})

                    Record.create!({recordable_type: 'WacsBacsRssm',
                                    recordable_id: tcr.id,
                                    name: wbhash['record_name']})
                  end
                end
              end
            end
          end

        end

        ### THIS IS REDUNDANT?
        ### DOES THIS WORK? TEST!!
        #@eefps_t1_link_dict.each do |t2_eefps_id, t1_eefps_source_id|
        #  ExtractionsExtractionFormsProjectsSection.find(t2_eefps_id).update!(link_to_type1: @id_map['eefps'][t1_eefps_source_id])
        #end

        shash['records']&.each do |qrcfid, rhash|
          qrcf = @id_map['qrcf'][qrcfid]
          eefpsqrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by! extractions_extraction_forms_projects_section: eefps,
                                                                                                          question_row_column_field: qrcf

          begin
            Record.find_or_create_by! recordable_type: 'ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField',
                                      recordable_id: eefpsqrcf.id,
                                      name: rhash['name'] || ""
          rescue => err
            byebug
          end
        end
      end
    end
  end
end