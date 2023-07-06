# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_07_06_090800) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "authorizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "provider"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["provider", "uid"], name: "index_authorizations_on_provider_and_uid"
    t.index ["user_id"], name: "index_authorizations_on_user_id"
  end

  create_table "black_list", force: :cascade do |t|
    t.string "birthday"
    t.string "first_name"
    t.string "last_name"
    t.string "patronymic"
  end

  create_table "bookmate_all", id: false, force: :cascade do |t|
    t.integer "daybirth"
    t.text "email"
    t.json "information"
    t.text "middlename"
    t.integer "monthbirth"
    t.text "name"
    t.text "surname"
    t.integer "yearbirth"
  end

  create_table "clients", id: false, force: :cascade do |t|
    t.string "config"
    t.string "description"
    t.uuid "id"
    t.string "jwt_token"
    t.string "login"
    t.string "password"
    t.integer "request_count"
  end

  create_table "expired_passports", force: :cascade do |t|
    t.string "passp_number"
    t.string "passp_series"
    t.index ["passp_series"], name: "expired_passports_passp_series_index"
  end

  create_table "femida_retro_users", force: :cascade do |t|
    t.string "birth_date"
    t.string "first_name"
    t.boolean "is_passport_verified"
    t.boolean "is_phone_verified"
    t.string "last_name"
    t.string "middle_name"
    t.string "passport"
    t.string "phone"
  end

  create_table "fssp_wanted", force: :cascade do |t|
    t.string "birthday"
    t.string "first_name"
    t.string "last_name"
    t.string "patronymic"
    t.string "region_id"
  end

  create_table "kinokassa_ru_orders", id: false, force: :cascade do |t|
    t.text "email"
    t.json "information"
    t.text "phone"
    t.index ["phone"], name: "index_kinokassa_ru_orders_on_phone"
  end

  create_table "lukoil_txt", id: false, force: :cascade do |t|
    t.text "middlename"
    t.text "name"
    t.text "phone"
    t.text "surname"
    t.index ["phone"], name: "index_lukoil_txt_on_phone"
  end

  create_table "moneyman_users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "middle_name"
    t.string "passport"
    t.string "phone"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.bigint "resource_owner_id", null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes", default: "", null: false
    t.string "token", null: false
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "expires_in"
    t.string "previous_refresh_token", default: "", null: false
    t.string "refresh_token"
    t.bigint "resource_owner_id"
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.string "token", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.string "secret", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "one_more_lz2", id: false, force: :cascade do |t|
    t.text "Car"
    t.text "DayBirth"
    t.text "FirstName"
    t.text "Info"
    t.text "Inn"
    t.text "LastName"
    t.text "MiddleName"
    t.text "MonthBirth"
    t.text "Passport"
    t.text "Snils"
    t.text "Telephone"
    t.text "YearBirth"
    t.text "index"
    t.index ["Telephone"], name: "index_one_more_lz2_on_Telephone"
    t.index ["index"], name: "ix_lz2_index"
  end

  create_table "opendata", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "filename"
    t.string "number"
    t.string "rows"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "opendata_customs92", force: :cascade do |t|
    t.string "start_date"
    t.string "vehicle_body_number"
    t.string "vehicle_chassis_number"
    t.string "vehicle_from_country"
    t.string "vehicle_from_country_naim"
    t.string "vehicle_vin"
  end

  create_table "opendata_fsrar", force: :cascade do |t|
    t.string "address_1"
    t.string "address_2"
    t.string "change_date"
    t.string "coords"
    t.string "doc_num"
    t.string "email"
    t.string "inn"
    t.string "kind"
    t.string "kpp"
    t.string "kpp_2"
    t.string "license_from"
    t.string "license_info"
    t.string "license_info_basis"
    t.string "license_info_history"
    t.string "license_info_updated_date"
    t.string "license_num"
    t.string "license_organ"
    t.string "license_to"
    t.string "name"
    t.string "product_type"
    t.string "reestr_num"
    t.string "region_code"
    t.string "region_code_2"
    t.string "service_date"
    t.string "service_info"
  end

  create_table "opendata_fssp6", force: :cascade do |t|
    t.string "actual_address"
    t.string "address"
    t.string "amount_due"
    t.string "date_proceeding"
    t.string "debt"
    t.string "debtor_tin"
    t.string "departments"
    t.string "departments_address"
    t.string "doc_date"
    t.string "doc_number"
    t.string "doc_type"
    t.string "docs_object"
    t.string "execution_object"
    t.string "name"
    t.string "number_proceeding"
    t.string "tin_collector"
    t.string "total_number_proceedings"
  end

  create_table "opendata_fssp7", force: :cascade do |t|
    t.string "actual_address"
    t.string "address"
    t.string "complete_reason_date"
    t.string "date_proceeding"
    t.string "debtor_tin"
    t.string "departments"
    t.string "departments_address"
    t.string "doc_date"
    t.string "doc_number"
    t.string "doc_type"
    t.string "docs_object"
    t.string "execution_object"
    t.string "name"
    t.string "number_proceeding"
    t.string "tin_collector"
    t.string "total_number_proceedings"
  end

  create_table "opendata_nalog77", force: :cascade do |t|
    t.string "name"
  end

  create_table "opendata_rkn10", force: :cascade do |t|
    t.string "AnnulledInfo"
    t.string "Date"
    t.string "DateFrom"
    t.string "DateTo"
    t.string "Num"
    t.string "Owner"
    t.string "Place"
    t.string "RenewalInfo"
    t.string "SuspensionInfo"
    t.string "Type"
  end

  create_table "opendata_rkn13", force: :cascade do |t|
    t.string "address"
    t.string "address_activity"
    t.string "control_form"
    t.string "date_last"
    t.string "date_reg"
    t.string "date_start"
    t.string "goal"
    t.string "inn"
    t.string "ogrn"
    t.string "org_name"
    t.string "orgs"
    t.string "plan_year"
    t.string "work_day_cnt"
  end

  create_table "opendata_rkn14", force: :cascade do |t|
    t.string "measure"
    t.string "name"
    t.string "okei"
    t.string "rowNumber"
    t.string "totalSum"
  end

  create_table "opendata_rkn18", force: :cascade do |t|
    t.string "accreditationDate"
    t.string "degree"
    t.string "education"
    t.string "email"
    t.string "expertiseSubject"
    t.string "name"
    t.string "orderNum"
    t.string "status"
    t.string "validity"
  end

  create_table "opendata_rkn2", force: :cascade do |t|
    t.string "addr_legal"
    t.string "date_end"
    t.string "date_start"
    t.string "lic_status_name"
    t.string "licence_num"
    t.string "name"
    t.string "name_short"
    t.string "ownership"
    t.string "registration"
    t.string "service_name"
    t.string "territory"
  end

  create_table "opendata_rkn20", force: :cascade do |t|
    t.string "distributorEmail"
    t.string "distributorINN"
    t.string "distributorLegalAddress"
    t.string "distributorName"
    t.string "distributorOGRN"
    t.string "distributorPersons"
    t.string "entryDate"
    t.string "entryNum"
    t.string "services"
  end

  create_table "opendata_rkn26", force: :cascade do |t|
    t.string "entryDate"
    t.string "entryNum"
    t.string "owner"
    t.string "serviceName"
  end

  create_table "opendata_rkn3", force: :cascade do |t|
    t.string "annulled_date"
    t.string "domain_name"
    t.string "form_spread"
    t.string "form_spread_id"
    t.string "founders"
    t.string "langs"
    t.string "name"
    t.string "reg_date"
    t.string "reg_number"
    t.string "reg_number_id"
    t.string "rus_name"
    t.string "staff_address"
    t.string "status_comment"
    t.string "status_id"
    t.string "suspension_date"
    t.string "termination_date"
    t.string "territory"
    t.string "territory_ids"
  end

  create_table "opendata_rkn5", force: :cascade do |t|
    t.string "cancellation_date"
    t.string "cancellation_num"
    t.string "geo_zone"
    t.string "license_num"
    t.string "location"
    t.string "order_date"
    t.string "order_num"
    t.string "org_name"
    t.string "regno"
    t.string "short_org_name"
  end

  create_table "opendata_rkn6", force: :cascade do |t|
    t.string "address"
    t.string "basis"
    t.string "db_country"
    t.string "encryption"
    t.string "enter_date"
    t.string "enter_order"
    t.string "enter_order_date"
    t.string "enter_order_num"
    t.string "income_date"
    t.string "inn"
    t.string "is_list"
    t.string "name_full"
    t.string "pd_operator_num"
    t.string "purpose_txt"
    t.string "resp_name"
    t.string "rf_subjects"
    t.string "startdate"
    t.string "status"
    t.string "stop_condition"
    t.string "territory"
    t.string "transgran"
  end

  create_table "opendata_rosstat2012", force: :cascade do |t|
    t.string "inn"
    t.string "measure"
    t.string "name"
    t.string "okfs"
    t.string "okopf"
    t.string "okpo"
    t.string "okved"
    t.string "type"
  end

  create_table "opendata_rosstat2013", force: :cascade do |t|
    t.string "inn"
    t.string "measure"
    t.string "name"
    t.string "okfs"
    t.string "okopf"
    t.string "okpo"
    t.string "okved"
    t.string "type"
  end

  create_table "opendata_rosstat2014", force: :cascade do |t|
    t.string "inn"
    t.string "measure"
    t.string "name"
    t.string "okfs"
    t.string "okopf"
    t.string "okpo"
    t.string "okved"
    t.string "type"
  end

  create_table "opendata_rosstat2015", force: :cascade do |t|
    t.string "inn"
    t.string "measure"
    t.string "name"
    t.string "okfs"
    t.string "okopf"
    t.string "okpo"
    t.string "okved"
    t.string "type"
  end

  create_table "opendata_rosstat2016", force: :cascade do |t|
    t.string "inn"
    t.string "measure"
    t.string "name"
    t.string "okfs"
    t.string "okopf"
    t.string "okpo"
    t.string "okved"
    t.string "type"
  end

  create_table "opendata_rosstat2017", force: :cascade do |t|
    t.string "inn"
    t.string "measure"
    t.string "name"
    t.string "okfs"
    t.string "okopf"
    t.string "okpo"
    t.string "okved"
    t.string "type"
  end

  create_table "opendata_rosstat2018", force: :cascade do |t|
    t.string "inn"
    t.string "measure"
    t.string "name"
    t.string "okfs"
    t.string "okopf"
    t.string "okpo"
    t.string "okved"
    t.string "type"
  end

  create_table "oriflame_ru", id: false, force: :cascade do |t|
    t.integer "daybirth"
    t.text "email"
    t.json "information"
    t.text "middlename"
    t.integer "monthbirth"
    t.text "name"
    t.text "phone"
    t.text "surname"
    t.integer "yearbirth"
    t.index ["phone"], name: "index_oriflame_ru_on_phone"
  end

  create_table "parsed_users", force: :cascade do |t|
    t.string "address"
    t.string "birth_date"
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "is_phone_verified"
    t.string "last_name"
    t.string "middle_name"
    t.string "passport"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["passport"], name: "index_parsed_users_on_passport"
    t.index ["phone"], name: "index_parsed_users_on_phone"
  end

  create_table "pdl", id: false, force: :cascade do |t|
    t.string "dob"
    t.serial "id", null: false
    t.string "inn"
    t.string "last_job_title"
    t.string "oif"
    t.string "rank"
  end

  create_table "phone_rates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "phone"
    t.float "rate"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "skyeng_full_csv", id: false, force: :cascade do |t|
    t.integer "daybirth"
    t.text "email"
    t.json "information"
    t.integer "monthbirth"
    t.text "name"
    t.text "phone"
    t.text "surname"
    t.integer "yearbirth"
    t.index ["phone"], name: "index_skyeng_full_csv_on_phone"
  end

  create_table "sogaz", id: false, force: :cascade do |t|
    t.text "birth_day"
    t.text "birth_month"
    t.text "birth_year"
    t.text "email"
    t.text "first_name"
    t.text "information"
    t.text "last_name"
    t.text "phone"
    t.text "second_name"
    t.index ["phone"], name: "index_sogaz_on_phone"
  end

  create_table "sro", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "full_name"
    t.string "inn"
    t.integer "number"
    t.string "ogrn"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.string "website"
  end

  create_table "sro_kinds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date"
    t.string "kind"
    t.integer "sro_id"
    t.integer "sro_member_id"
    t.date "start_date"
    t.datetime "updated_at", null: false
  end

  create_table "sro_members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "full_name"
    t.string "inn"
    t.string "ogrn"
    t.integer "sro_id"
    t.datetime "updated_at", null: false
  end

  create_table "terrorist_list", force: :cascade do |t|
    t.string "date_of_birth"
    t.string "first_name"
    t.string "last_name"
    t.string "middlename"
  end

  create_table "turbozaim_user_data", force: :cascade do |t|
    t.string "actual_date"
    t.string "address"
    t.string "birthdate"
    t.string "birthplace"
    t.string "citizenship"
    t.datetime "created_at", null: false
    t.string "credit_sum"
    t.string "credit_type"
    t.string "date"
    t.string "date_from"
    t.string "delo_article"
    t.string "delo_date"
    t.string "delo_date2"
    t.string "delo_initiator"
    t.string "delo_num"
    t.string "email"
    t.string "fact_address"
    t.string "fact_region"
    t.string "field0"
    t.string "field1"
    t.string "field2"
    t.string "field3"
    t.string "field4"
    t.string "field5"
    t.string "field6"
    t.string "field7"
    t.string "field8"
    t.string "field9"
    t.string "ifns"
    t.string "info"
    t.string "inn"
    t.string "insurance"
    t.string "kbm"
    t.string "limitation"
    t.string "model"
    t.string "name"
    t.string "nationality"
    t.string "ogrn"
    t.string "old_address"
    t.string "old_birthdate"
    t.string "old_first_name"
    t.string "old_last_name"
    t.string "old_middle_name"
    t.string "organization"
    t.string "organization_inn"
    t.string "overdue_days"
    t.string "passport"
    t.string "passport_date"
    t.string "passport_organ"
    t.string "phone"
    t.string "phone2"
    t.string "phone3"
    t.string "polis"
    t.string "premium_sum"
    t.string "registration_address"
    t.string "registration_region"
    t.string "snils"
    t.string "source"
    t.string "sum"
    t.string "target"
    t.string "turbozaim_user_id"
    t.datetime "updated_at", null: false
    t.string "vin"
    t.string "workplace"
    t.string "workplace_address"
    t.string "workplace_phone"
    t.string "workplace_position"
  end

  create_table "turbozaim_users", force: :cascade do |t|
    t.string "archive_fssp"
    t.string "birth_date"
    t.datetime "created_at", null: false
    t.string "dateopen"
    t.string "femida_id"
    t.string "first_name"
    t.string "has_double_citizenship"
    t.string "is_18"
    t.string "is_expired_passport"
    t.string "is_in_black_list"
    t.string "is_massive_supervisors"
    t.string "is_passport_verified"
    t.string "is_pdl"
    t.string "is_phone_verified"
    t.string "is_terrorist"
    t.string "last_name"
    t.string "middlename"
    t.string "os_inns"
    t.string "os_passports"
    t.string "os_phones"
    t.string "os_snils"
    t.string "os_status"
    t.string "passport"
    t.string "phone"
    t.string "turbozaim_id"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.string "name"
    t.string "phone"
    t.string "provider"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "token"
    t.string "uid"
    t.datetime "updated_at", null: false
  end

  create_table "users_massive_supervisors", force: :cascade do |t|
    t.string "g1"
    t.string "g2"
    t.string "g3"
    t.string "g4"
    t.string "g5"
  end

  create_table "xfit_users", id: false, force: :cascade do |t|
    t.integer "daybirth"
    t.text "email"
    t.json "information"
    t.text "middlename"
    t.integer "monthbirth"
    t.text "name"
    t.text "phone"
    t.text "surname"
    t.integer "yearbirth"
    t.index ["phone"], name: "index_xfit_users_on_phone"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "authorizations", "users"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
end
