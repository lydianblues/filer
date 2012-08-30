class Document < ActiveRecord::Base
  has_many :links
  has_many :folders, through: :links

  attr_accessible :content, :name, :remote_document_url
  mount_uploader :content, DocumentUploader
    
  module DataTables

    # This defines the column order in the rows presented 
    # by DataTables.
    ColumnMap = [
      "id",
      "name",
      "created_at", # really, uploaded_at
      "size",
      "content_type",
      "checksum"
    ]

    def dt_query(params)
      documents = Arel::Table.new(:documents)
      links = Arel::Table.new(:links)
      folder_id = sanitize_sql(params[:folder_id])

      query = documents
        .join(links).on(links[:document_id].eq(documents[:id]))
        .group(documents[:id]).group(links[:id])
        .where(links[:folder_id].eq(folder_id))

      # Search across all columns.
      sSearch = params["sSearch"]
    
      # Search all searchable columns with one search string.
      search = nil
      unless sSearch.blank?
        pattern = '%' + sanitize_sql(sSearch) + '%'
        for n in 0..(ColumnMap.length - 1)
          if params["bSearchable_#{n}"] == 'true'
            col = ColumnMap[n]
            t = documents[col].matches(pattern)
            if search
                search.or(t)
            else
              search = t
            end
          end
        end
      end
      query.where(search) if search
    
      # Search all searchable columns with a different search 
      # string for each columnn.
      search = nil
      for n in 0..(ColumnMap.length - 1)
        col = ColumnMap[n]
        if params["bSearchable_#{n}"] == 'true' &&
          params["sSearch_#{n}"].present?
          pattern = '%' + sanitize_sql(params["sSearch_#{n}"]) + '%'
          t = documents[col].matches(pattern)
          if search
            search.or(t)
          else
            search = t
          end
        end
      end
      query.where(search) if search
      
      count_query = query.clone.project('count(*)')
      total_matches = Document.find_by_sql(count_query).length
      
      if params["iSortCol_0"]
         iSortCol_0 = params["iSortCol_0"]
         iSortingCols = params["iSortingCols"].to_i
         for n in 0..(iSortingCols - 1)
           sort_col_idx = params["iSortCol_#{n}"].to_i
           if params["bSortable_#{sort_col_idx}"] == "true"
             dir = params["sSortDir_#{sort_col_idx}"]
             dir = "asc" if dir.blank?
           end
           col = ColumnMap[sort_col_idx]

           d = documents[col].send(dir)
           query.order(d)
         end
       end
      
      # Paging
      if params["iDisplayStart"] 
        iDisplayStart =  params["iDisplayStart"].to_i
        iDisplayLength = params["iDisplayLength"].to_i
        if iDisplayLength != -1
          query = query.take(iDisplayLength).skip(iDisplayStart)
        end
      end

      total_records = Document.entries_for_folder(params["folder_id"]).size
      results = Document.find_by_sql(query.project(Arel.sql('*')))
      format_results(results, total_records, total_matches, params["sEcho"])
    end

    private

    def format_results(results, total_records, total_matches, echo)
      Rails.logger.info "total_records = #{total_records}, " +
          "total_matches = #{total_matches}"
      records = {
        "sEcho" => echo.to_i,
        "iTotalRecords" => total_records.to_i,
        "iTotalDisplayRecords" => total_matches.to_i,
        "aaData" => []
      }
      data = []
      results.each do |r|
        data << [
          r.id,
          "<a href=\"#{r.content.url}\">#{r.name}</a>",
          r.created_at.localtime.strftime("%m/%d/%Y %I:%M%p"),
          r.size,
          r.content_type,
          r.checksum || 0
         ]
      end
      records["aaData"] = data
      Rails.logger.info(records.to_json)
      records
    end
  end

  extend DataTables

  # So folder_document_path will be defined.
  include Rails.application.routes.url_helpers
  
  def self.entries_for_folder(folder_id)
    joins(:links).where("links.folder_id =  ?", folder_id)
  end

   # 
   # One convenient method to pass jq_upload the necessary information.
   #
   def to_jq_upload(folder_id)
     {
       "name" => read_attribute(:content),
       "size" => content.size,
       "url" => content.url,
       # "thumbnail_url" => content.thumb.url,
       "delete_url" => folder_upload_path(folder_id: folder_id, id: self.id),
       "delete_type" => "DELETE" 
     }
   end

end
