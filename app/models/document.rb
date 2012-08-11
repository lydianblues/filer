class Document < ActiveRecord::Base
  has_many :links
  has_many :folders, through: :links

  attr_accessible :content, :name, :remote_document_url
  mount_uploader :content, DocumentUploader
  
  module DataTables

    # This defines the column order in the rows presented 
    # by DataTables.
    ColumnMap = [
      "name",
      "created_at", # really, uploaded_at
      "size",
      "checksum"
    ]

    def dt_query(params)
      query = Document.joins(:links)
        .where('links.folder_id = ?', params[:folder_id])

      # Paging
      if params["iDisplayStart"] 
        iDisplayStart =  params["iDisplayStart"].to_i
        iDisplayLength = params["iDisplayLength"].to_i
        if iDisplayLength != -1
          query = query.limit(iDisplayLength).offset(iDisplayStart)
        end
      end

      # Ordering
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
          query = query.order(col + " " + dir)
        end
      end

      # Search across all columns.
      sSearch = params["sSearch"]
    
      # This is overly general.  In the filer application we will only
      # search the "name" column.
      unless sSearch.blank?
        for n in 0..(ColumnMap.length - 1)
          col = ColumnMap[n]
          query = query.where("#{col} LIKE ?", '%' + sanitize_sql(sSearch) + '%')
        end
      end
    
      # Individidual column search.
      for n in 0..(ColumnMap.length - 1)
        col = ColumnMap[n]
        if params["bSearchable_#{n}"] == 'true' &&
          params["sSearch_#{n}"].present?
          query = query.where("col LIKE ?",
            '%' + sanitize_sql(params["sSearch_#{n}"]) + '%')
        end
      end

      total_records = Document.entries_for_folder(params["folder_id"]).size
      results = query.all
      format_results(results, total_records, params["sEcho"])
    end

    private

    def format_results(results, total, echo)
      records = {
        "sEcho" => echo.to_i,
        "iTotalRecords" => total.to_i,
        "iTotalDisplayRecords" => results.size + 2, # XXX
        "aaData" => []
      }
      data = []
      results.each do |r|
        data << [
          r.name,
          r.created_at,
          r.size || 0,
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
