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

ActiveRecord::Schema[7.0].define(version: 2023_10_11_100000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"
  enable_extension "postgres_fdw"

  create_table "action", id: :integer, default: nil, comment: "An action is something you can do, such as run a readwrite query", force: :cascade do |t|
    t.boolean "archived", default: false, null: false, comment: "Whether or not the action has been archived"
    t.timestamptz "created_at", default: -> { "now()" }, null: false, comment: "The timestamp of when the action was created"
    t.integer "creator_id", comment: "The user who created the action"
    t.text "description", comment: "The description of the action"
    t.string "entity_id", limit: 21, comment: "Random NanoID tag for unique identity."
    t.integer "made_public_by_id", comment: "The ID of the User who first publically shared this Action."
    t.integer "model_id", null: false, comment: "The associated model"
    t.string "name", limit: 254, null: false, comment: "The name of the action"
    t.text "parameter_mappings", comment: "The saved parameter mappings for this action"
    t.text "parameters", comment: "The saved parameters for this action"
    t.string "public_uuid", limit: 36, comment: "Unique UUID used to in publically-accessible links to this Action."
    t.text "type", null: false, comment: "Type of action"
    t.timestamptz "updated_at", default: -> { "now()" }, null: false, comment: "The timestamp of when the action was updated"
    t.text "visualization_settings", comment: "The UI visualization_settings for this action"
    t.index ["creator_id"], name: "idx_action_creator_id"
    t.index ["entity_id"], name: "action_entity_id_key", unique: true
    t.index ["public_uuid"], name: "action_public_uuid_key", unique: true
    t.index ["public_uuid"], name: "idx_action_public_uuid"
  end

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

  create_table "activity", id: :integer, default: nil, force: :cascade do |t|
    t.string "custom_id", limit: 48
    t.integer "database_id"
    t.text "details", null: false
    t.string "model", limit: 16
    t.integer "model_id"
    t.integer "table_id"
    t.timestamptz "timestamp", null: false
    t.string "topic", limit: 32, null: false
    t.integer "user_id"
    t.index ["custom_id"], name: "idx_activity_custom_id"
    t.index ["timestamp"], name: "idx_activity_timestamp"
    t.index ["user_id"], name: "idx_activity_user_id"
  end

  create_table "application_permissions_revision", id: :integer, default: nil, comment: "Used to keep track of changes made to general permissions.", force: :cascade do |t|
    t.text "after", null: false, comment: "Serialized JSON of the changes in permission graph."
    t.text "before", null: false, comment: "Serialized JSON of the permission graph before the changes."
    t.datetime "created_at", precision: nil, null: false, comment: "The timestamp of when these changes were made."
    t.text "remark", comment: "Optional remarks explaining why these changes were made."
    t.integer "user_id", null: false, comment: "The ID of the admin who made this set of changes."
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

  create_table "bookmark_ordering", id: :integer, default: nil, comment: "Table holding ordering information for various bookmark tables", force: :cascade do |t|
    t.integer "item_id", null: false, comment: "id of the item being bookmarked (Card, Collection, Dashboard, ...) no FK, so may no longer exist"
    t.integer "ordering", null: false, comment: "order of bookmark for user"
    t.string "type", limit: 255, null: false, comment: "type of the Bookmark"
    t.integer "user_id", null: false, comment: "ID of the User who ordered bookmarks"
    t.index ["user_id", "ordering"], name: "unique_bookmark_user_id_ordering", unique: true
    t.index ["user_id", "type", "item_id"], name: "unique_bookmark_user_id_type_item_id", unique: true
    t.index ["user_id"], name: "idx_bookmark_ordering_user_id"
  end

  create_table "card_bookmark", id: :integer, default: nil, comment: "Table holding bookmarks on cards", force: :cascade do |t|
    t.integer "card_id", null: false, comment: "ID of the Card bookmarked by the user"
    t.timestamptz "created_at", default: -> { "now()" }, null: false, comment: "The timestamp of when the bookmark was created"
    t.integer "user_id", null: false, comment: "ID of the User who bookmarked the Card"
    t.index ["card_id"], name: "idx_card_bookmark_card_id"
    t.index ["user_id", "card_id"], name: "unique_card_bookmark_user_id_card_id", unique: true
    t.index ["user_id"], name: "idx_card_bookmark_user_id"
  end

  create_table "card_label", id: :integer, default: nil, force: :cascade do |t|
    t.integer "card_id", null: false
    t.integer "label_id", null: false
    t.index ["card_id", "label_id"], name: "unique_card_label_card_id_label_id", unique: true
    t.index ["card_id"], name: "idx_card_label_card_id"
    t.index ["label_id"], name: "idx_card_label_label_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "birthday"
    t.string "card"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "middle_name"
    t.string "phone"
    t.index ["phone"], name: "index_cards_on_phone"
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

  create_table "collection", id: :integer, default: nil, comment: "Collections are an optional way to organize Cards and handle permissions for them.", force: :cascade do |t|
    t.boolean "archived", default: false, null: false, comment: "Whether this Collection has been archived and should be hidden from users."
    t.string "authority_level", limit: 255, comment: "Nullable column to incidate collection's authority level. Initially values are \"official\" and nil."
    t.string "color", limit: 7, null: false, comment: "Seven-character hex color for this Collection, including the preceding hash sign."
    t.timestamptz "created_at", default: -> { "now()" }, null: false, comment: "Timestamp of when this Collection was created."
    t.text "description", comment: "Optional description for this Collection."
    t.string "entity_id", limit: 21, comment: "Random NanoID tag for unique identity."
    t.string "location", limit: 254, default: "/", null: false, comment: "Directory-structure path of ancestor Collections. e.g. \"/1/2/\" means our Parent is Collection 2, and their parent is Collection 1."
    t.text "name", null: false, comment: "The user-facing name of this Collection."
    t.string "namespace", limit: 254, comment: "The namespace (hierachy) this Collection belongs to. NULL means the Collection is in the default namespace."
    t.integer "personal_owner_id", comment: "If set, this Collection is a personal Collection, for exclusive use of the User with this ID."
    t.string "slug", limit: 254, null: false, comment: "Sluggified version of the Collection name. Used only for display purposes in URL; not unique or indexed."
    t.string "type", limit: 256, comment: "This is used to differentiate instance-analytics collections from all other collections."
    t.index ["entity_id"], name: "collection_entity_id_key", unique: true
    t.index ["location"], name: "idx_collection_location"
    t.index ["personal_owner_id"], name: "idx_collection_personal_owner_id"
    t.index ["personal_owner_id"], name: "unique_collection_personal_owner_id", unique: true
  end

  create_table "collection_bookmark", id: :integer, default: nil, comment: "Table holding bookmarks on collections", force: :cascade do |t|
    t.integer "collection_id", null: false, comment: "ID of the Card bookmarked by the user"
    t.timestamptz "created_at", default: -> { "now()" }, null: false, comment: "The timestamp of when the bookmark was created"
    t.integer "user_id", null: false, comment: "ID of the User who bookmarked the Collection"
    t.index ["collection_id"], name: "idx_collection_bookmark_collection_id"
    t.index ["user_id", "collection_id"], name: "unique_collection_bookmark_user_id_collection_id", unique: true
    t.index ["user_id"], name: "idx_collection_bookmark_user_id"
  end

  create_table "collection_permission_graph_revision", id: :integer, default: nil, comment: "Used to keep track of changes made to collections.", force: :cascade do |t|
    t.text "after", null: false, comment: "Serialized JSON of the collections graph after the changes."
    t.text "before", null: false, comment: "Serialized JSON of the collections graph before the changes."
    t.datetime "created_at", precision: nil, null: false, comment: "The timestamp of when these changes were made."
    t.text "remark", comment: "Optional remarks explaining why these changes were made."
    t.integer "user_id", null: false, comment: "The ID of the admin who made this set of changes."
  end

  create_table "computation_job", id: :integer, default: nil, comment: "Stores submitted async computation jobs.", force: :cascade do |t|
    t.text "context"
    t.datetime "created_at", precision: nil, null: false
    t.integer "creator_id"
    t.datetime "ended_at", precision: nil
    t.string "status", limit: 254, null: false
    t.string "type", limit: 254, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "computation_job_result", id: :integer, default: nil, comment: "Stores results of async computation jobs.", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "job_id", null: false
    t.text "payload", null: false
    t.string "permanence", limit: 254, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "connection_impersonations", id: :integer, default: nil, comment: "Table for holding connection impersonation policies", force: :cascade do |t|
    t.text "attribute", comment: "User attribute associated with the database role to use for this connection impersonation policy"
    t.integer "db_id", null: false, comment: "ID of the database this connection impersonation policy affects"
    t.integer "group_id", null: false, comment: "ID of the permissions group this connection impersonation policy affects"
    t.index ["db_id"], name: "idx_conn_impersonations_db_id"
    t.index ["group_id", "db_id"], name: "conn_impersonation_unique_group_id_db_id", unique: true
    t.index ["group_id"], name: "idx_conn_impersonations_group_id"
  end

  create_table "core_session", id: { type: :string, limit: 254 }, force: :cascade do |t|
    t.text "anti_csrf_token", comment: "Anti-CSRF token for full-app embed sessions."
    t.timestamptz "created_at", null: false
    t.integer "user_id", null: false
  end

  create_table "core_user", id: :integer, default: nil, force: :cascade do |t|
    t.timestamptz "date_joined", null: false
    t.citext "email", null: false
    t.string "first_name", limit: 254
    t.boolean "is_active", default: true, null: false
    t.boolean "is_datasetnewb", default: true, null: false, comment: "Boolean flag to indicate if the dataset info modal has been dismissed."
    t.boolean "is_qbnewb", default: true, null: false
    t.boolean "is_superuser", default: false, null: false
    t.timestamptz "last_login"
    t.string "last_name", limit: 254
    t.string "locale", limit: 5, comment: "Preferred ISO locale (language/country) code, e.g \"en\" or \"en-US\", for this User. Overrides site default."
    t.text "login_attributes", comment: "JSON serialized map with attributes used for row level permissions"
    t.string "password", limit: 254
    t.string "password_salt", limit: 254, default: "default"
    t.string "reset_token", limit: 254
    t.bigint "reset_triggered"
    t.text "settings", comment: "Serialized JSON containing User-local Settings for this User"
    t.string "sso_source", limit: 254, comment: "String to indicate the SSO backend the user is from"
    t.datetime "updated_at", precision: nil, comment: "When was this User last updated?"
    t.index "lower((email)::text)", name: "idx_lower_email"
    t.index ["email"], name: "core_user_email_key", unique: true
  end

  create_table "csv_parser_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "csv_parser_id"
    t.string "info"
    t.integer "is_card_verified_count"
    t.integer "is_passport_verified_count"
    t.integer "is_phone_verified_count"
    t.datetime "updated_at", null: false
  end

  create_table "csv_parsers", force: :cascade do |t|
    t.integer "birth_date"
    t.string "date_mask"
    t.integer "external_id"
    t.integer "file_id"
    t.integer "first_name"
    t.string "headers"
    t.integer "info"
    t.integer "is_card_verified_count"
    t.integer "is_passport_verified_count"
    t.integer "is_phone_verified_count"
    t.integer "last_name"
    t.integer "middle_name"
    t.integer "passport"
    t.integer "phone"
    t.integer "rows"
    t.string "score_uuid"
    t.string "separator"
    t.integer "status", default: 0
  end

  create_table "csv_users", force: :cascade do |t|
    t.string "birth_date"
    t.string "external_id"
    t.decimal "file_id"
    t.string "first_name"
    t.text "info"
    t.boolean "is_card_verified"
    t.string "is_card_verified_source"
    t.boolean "is_passport_verified"
    t.string "is_passport_verified_source"
    t.boolean "is_phone_verified"
    t.string "is_phone_verified_source"
    t.string "last_name"
    t.string "middle_name"
    t.string "passport"
    t.string "phone"
    t.string "phone_score"
    t.string "phone_score_source"
    t.index ["passport"], name: "index_csv_users_on_passport"
    t.index ["phone"], name: "index_csv_users_on_phone"
  end

  create_table "dashboard_bookmark", id: :integer, default: nil, comment: "Table holding bookmarks on dashboards", force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false, comment: "The timestamp of when the bookmark was created"
    t.integer "dashboard_id", null: false, comment: "ID of the Dashboard bookmarked by the user"
    t.integer "user_id", null: false, comment: "ID of the User who bookmarked the Dashboard"
    t.index ["dashboard_id"], name: "idx_dashboard_bookmark_dashboard_id"
    t.index ["user_id", "dashboard_id"], name: "unique_dashboard_bookmark_user_id_dashboard_id", unique: true
    t.index ["user_id"], name: "idx_dashboard_bookmark_user_id"
  end

  create_table "dashboard_favorite", id: :integer, default: nil, comment: "Presence of a row here indicates a given User has favorited a given Dashboard.", force: :cascade do |t|
    t.integer "dashboard_id", null: false, comment: "ID of the Dashboard favorited by the User."
    t.integer "user_id", null: false, comment: "ID of the User who favorited the Dashboard."
    t.index ["dashboard_id"], name: "idx_dashboard_favorite_dashboard_id"
    t.index ["user_id", "dashboard_id"], name: "unique_dashboard_favorite_user_id_dashboard_id", unique: true
    t.index ["user_id"], name: "idx_dashboard_favorite_user_id"
  end

  create_table "dashboard_tab", id: :integer, default: nil, comment: "Join table connecting dashboard to dashboardcards", force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false, comment: "The timestamp at which the tab was created"
    t.integer "dashboard_id", null: false, comment: "The dashboard that a tab is on"
    t.string "entity_id", limit: 21, null: false, comment: "Random NanoID tag for unique identity."
    t.text "name", null: false, comment: "Displayed name of the tab"
    t.integer "position", null: false, comment: "Position of the tab with respect to others tabs in dashboard"
    t.timestamptz "updated_at", default: -> { "now()" }, null: false, comment: "The timestamp at which the tab was last updated"
    t.index ["entity_id"], name: "dashboard_tab_entity_id_key", unique: true
  end

  create_table "dashboardcard_series", id: :integer, default: nil, force: :cascade do |t|
    t.integer "card_id", null: false
    t.integer "dashboardcard_id", null: false
    t.integer "position", null: false
    t.index ["card_id"], name: "idx_dashboardcard_series_card_id"
    t.index ["dashboardcard_id"], name: "idx_dashboardcard_series_dashboardcard_id"
  end

  create_table "data_migrations", id: { type: :string, limit: 254 }, force: :cascade do |t|
    t.datetime "timestamp", precision: nil, null: false
    t.index ["id"], name: "idx_data_migrations_id"
  end

  create_table "databasechangelog", id: false, force: :cascade do |t|
    t.string "author", limit: 255, null: false
    t.string "comments", limit: 255
    t.string "contexts", limit: 255
    t.datetime "dateexecuted", precision: nil, null: false
    t.string "deployment_id", limit: 10
    t.string "description", limit: 255
    t.string "exectype", limit: 10, null: false
    t.string "filename", limit: 255, null: false
    t.string "id", limit: 255, null: false
    t.string "labels", limit: 255
    t.string "liquibase", limit: 20
    t.string "md5sum", limit: 35
    t.integer "orderexecuted", null: false
    t.string "tag", limit: 255
    t.index ["id", "author", "filename"], name: "idx_databasechangelog_id_author_filename", unique: true
  end

  create_table "databasechangeloglock", id: :integer, default: nil, force: :cascade do |t|
    t.boolean "locked", null: false
    t.string "lockedby", limit: 255
    t.datetime "lockgranted", precision: nil
  end

  create_table "dependency", id: :integer, default: nil, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.integer "dependent_on_id", null: false
    t.string "dependent_on_model", limit: 32, null: false
    t.string "model", limit: 32, null: false
    t.integer "model_id", null: false
    t.index ["dependent_on_id"], name: "idx_dependency_dependent_on_id"
    t.index ["dependent_on_model"], name: "idx_dependency_dependent_on_model"
    t.index ["model"], name: "idx_dependency_model"
    t.index ["model_id"], name: "idx_dependency_model_id"
  end

  create_table "dimension", id: :integer, default: nil, comment: "Stores references to alternate views of existing fields, such as remapping an integer to a description, like an enum", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false, comment: "The timestamp of when the dimension was created."
    t.string "entity_id", limit: 21, comment: "Random NanoID tag for unique identity."
    t.integer "field_id", null: false, comment: "ID of the field this dimension row applies to"
    t.integer "human_readable_field_id", comment: "Only used with external type remappings. Indicates which field on the FK related table to use for display"
    t.string "name", limit: 254, null: false, comment: "Short description used as the display name of this new column"
    t.string "type", limit: 254, null: false, comment: "Either internal for a user defined remapping or external for a foreign key based remapping"
    t.datetime "updated_at", precision: nil, null: false, comment: "The timestamp of when these dimension was last updated."
    t.index ["entity_id"], name: "dimension_entity_id_key", unique: true
    t.index ["field_id"], name: "idx_dimension_field_id"
    t.index ["field_id"], name: "unique_dimension_field_id", unique: true
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

  create_table "http_action", primary_key: "action_id", id: { type: :integer, comment: "The related action", default: nil }, comment: "An http api call type of action", force: :cascade do |t|
    t.text "error_handle", comment: "A program to take an api response to determine if an error occurred"
    t.text "response_handle", comment: "A program to take an api response and transform to an appropriate response for emitters"
    t.text "template", null: false, comment: "A template that defines method,url,body,headers required to make an api call"
  end

  create_table "implicit_action", primary_key: "action_id", id: { type: :integer, comment: "The associated action", default: nil }, comment: "An action with dynamic parameters based on the underlying model", force: :cascade do |t|
    t.text "kind", null: false, comment: "The kind of implicit action create/update/delete"
  end

  create_table "label", id: :integer, default: nil, force: :cascade do |t|
    t.string "icon", limit: 128
    t.string "name", limit: 254, null: false
    t.string "slug", limit: 254, null: false
    t.index ["slug"], name: "idx_label_slug"
    t.index ["slug"], name: "label_slug_key", unique: true
  end

  create_table "login_history", id: :integer, default: nil, comment: "Keeps track of various logins for different users and additional info such as location and device", force: :cascade do |t|
    t.text "device_description", null: false, comment: "Description of the device that login happened from, for example a user-agent string, but this might be something different if we support alternative auth mechanisms in the future."
    t.string "device_id", limit: 36, null: false, comment: "Cookie-based unique identifier for the device/browser the user logged in from."
    t.text "ip_address", null: false, comment: "IP address of the device that login happened from, so we can geocode it and determine approximate location."
    t.string "session_id", limit: 254, comment: "ID of the Session created by this login if one is currently active. NULL if Session is no longer active."
    t.timestamptz "timestamp", default: -> { "now()" }, null: false, comment: "When this login occurred."
    t.integer "user_id", null: false, comment: "ID of the User that logged in."
    t.index ["session_id", "device_id"], name: "idx_user_id_device_id"
    t.index ["session_id"], name: "idx_session_id"
    t.index ["timestamp"], name: "idx_timestamp"
    t.index ["user_id", "timestamp"], name: "idx_user_id_timestamp"
    t.index ["user_id"], name: "idx_user_id"
  end

  create_table "metabase_database", id: :integer, default: nil, force: :cascade do |t|
    t.boolean "auto_run_queries", default: true, null: false, comment: "Whether to automatically run queries when doing simple filtering and summarizing in the Query Builder."
    t.string "cache_field_values_schedule", limit: 254, default: "0 50 0 * * ? *", null: false, comment: "The cron schedule string for when FieldValues for eligible Fields should be updated."
    t.integer "cache_ttl", comment: "Granular cache TTL for specific database."
    t.text "caveats"
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.integer "creator_id", comment: "ID of the admin who added the database"
    t.text "dbms_version", comment: "A JSON object describing the flavor and version of the DBMS."
    t.text "description"
    t.text "details", null: false
    t.string "engine", limit: 254, null: false
    t.string "initial_sync_status", limit: 32, default: "complete", null: false, comment: "String indicating whether a database has completed its initial sync and is ready to use"
    t.boolean "is_audit", default: false, null: false, comment: "Only the app db, visible to admins via auditing should have this set true."
    t.boolean "is_full_sync", default: true, null: false
    t.boolean "is_on_demand", default: false, null: false, comment: "Whether we should do On-Demand caching of FieldValues for this DB. This means FieldValues are updated when their Field is used in a Dashboard or Card param."
    t.boolean "is_sample", default: false, null: false
    t.string "metadata_sync_schedule", limit: 254, default: "0 50 * * * ? *", null: false, comment: "The cron schedule string for when this database should undergo the metadata sync process (and analysis for new fields)."
    t.string "name", limit: 254, null: false
    t.text "options", comment: "Serialized JSON containing various options like QB behavior."
    t.text "points_of_interest"
    t.boolean "refingerprint", comment: "Whether or not to enable periodic refingerprinting for this Database."
    t.text "settings", comment: "Serialized JSON containing Database-local Settings for this Database"
    t.string "timezone", limit: 254, comment: "Timezone identifier for the database, set by the sync process"
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
  end

  create_table "metabase_field", id: :integer, default: nil, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "base_type", limit: 255, null: false
    t.text "caveats"
    t.string "coercion_strategy", limit: 255, comment: "A strategy to coerce the base_type into the effective_type."
    t.timestamptz "created_at", null: false
    t.integer "custom_position", default: 0, null: false
    t.boolean "database_is_auto_increment", default: false, null: false, comment: "Indicates this field is auto incremented"
    t.integer "database_position", default: 0, null: false
    t.boolean "database_required", default: false, null: false, comment: "Indicates this field is required by the database for new records. Usually not null and without a default."
    t.text "database_type", null: false, comment: "The actual type of this column in the database. e.g. VARCHAR or TEXT."
    t.text "description"
    t.string "display_name", limit: 254
    t.string "effective_type", limit: 255, comment: "The effective type of the field after any coercions."
    t.text "fingerprint", comment: "Serialized JSON containing non-identifying information about this Field, such as min, max, and percent JSON. Used for classification."
    t.integer "fingerprint_version", default: 0, null: false, comment: "The version of the fingerprint for this Field. Used so we can keep track of which Fields need to be analyzed again when new things are added to fingerprints."
    t.integer "fk_target_field_id"
    t.text "has_field_values", comment: "Whether we have FieldValues (\"list\"), should ad-hoc search (\"search\"), disable entirely (\"none\"), or infer dynamically (null)\""
    t.boolean "json_unfolding", default: false, null: false, comment: "Enable/disable JSON unfolding for a field"
    t.timestamptz "last_analyzed"
    t.string "name", limit: 254, null: false
    t.string "nfc_path", limit: 254, comment: "Nested field column paths, flattened"
    t.integer "parent_id"
    t.text "points_of_interest"
    t.integer "position", default: 0, null: false
    t.boolean "preview_display", default: true, null: false
    t.string "semantic_type", limit: 255
    t.text "settings", comment: "Serialized JSON FE-specific settings like formatting, etc. Scope of what is stored here may increase in future."
    t.integer "table_id", null: false
    t.timestamptz "updated_at", null: false
    t.string "visibility_type", limit: 32, default: "normal", null: false
    t.index ["parent_id"], name: "idx_field_parent_id"
    t.index ["table_id", "name"], name: "idx_uniq_field_table_id_parent_id_name_2col", unique: true, where: "(parent_id IS NULL)"
    t.index ["table_id", "parent_id", "name"], name: "idx_uniq_field_table_id_parent_id_name", unique: true
    t.index ["table_id"], name: "idx_field_table_id"
  end

  create_table "metabase_fieldvalues", id: :integer, default: nil, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.integer "field_id", null: false
    t.boolean "has_more_values", default: false, comment: "true if the stored values list is a subset of all possible values"
    t.text "hash_key", comment: "Hash key for a cached fieldvalues"
    t.text "human_readable_values"
    t.timestamptz "last_used_at", default: -> { "now()" }, null: false, comment: "Timestamp of when these FieldValues were last used."
    t.string "type", limit: 32, default: "full", null: false, comment: "Type of FieldValues"
    t.timestamptz "updated_at", null: false
    t.text "values"
    t.index ["field_id"], name: "idx_fieldvalues_field_id"
  end

  create_table "metabase_table", id: :integer, default: nil, force: :cascade do |t|
    t.boolean "active", null: false
    t.text "caveats"
    t.timestamptz "created_at", null: false
    t.integer "db_id", null: false
    t.text "description"
    t.string "display_name", limit: 256
    t.string "entity_type", limit: 254
    t.string "field_order", limit: 254, default: "database", null: false
    t.string "initial_sync_status", limit: 32, default: "complete", null: false, comment: "String indicating whether a table has completed its initial sync and is ready to use"
    t.boolean "is_upload", default: false, null: false, comment: "Was the table created from user-uploaded (i.e., from a CSV) data?"
    t.string "name", limit: 256, null: false
    t.text "points_of_interest"
    t.string "schema", limit: 254
    t.boolean "show_in_getting_started", default: false, null: false
    t.timestamptz "updated_at", null: false
    t.string "visibility_type", limit: 254
    t.index ["db_id", "name"], name: "idx_uniq_table_db_id_schema_name_2col", unique: true, where: "(schema IS NULL)"
    t.index ["db_id", "schema", "name"], name: "idx_uniq_table_db_id_schema_name", unique: true
    t.index ["db_id", "schema"], name: "idx_metabase_table_db_id_schema"
    t.index ["db_id"], name: "idx_table_db_id"
    t.index ["show_in_getting_started"], name: "idx_metabase_table_show_in_getting_started"
  end

  create_table "metric", id: :integer, default: nil, force: :cascade do |t|
    t.boolean "archived", default: false, null: false
    t.text "caveats"
    t.timestamptz "created_at", null: false
    t.integer "creator_id", null: false
    t.text "definition", null: false
    t.text "description"
    t.string "entity_id", limit: 21, comment: "Random NanoID tag for unique identity."
    t.text "how_is_this_calculated"
    t.string "name", limit: 254, null: false
    t.text "points_of_interest"
    t.boolean "show_in_getting_started", default: false, null: false
    t.integer "table_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["creator_id"], name: "idx_metric_creator_id"
    t.index ["entity_id"], name: "metric_entity_id_key", unique: true
    t.index ["show_in_getting_started"], name: "idx_metric_show_in_getting_started"
    t.index ["table_id"], name: "idx_metric_table_id"
  end

  create_table "metric_important_field", id: :integer, default: nil, force: :cascade do |t|
    t.integer "field_id", null: false
    t.integer "metric_id", null: false
    t.index ["field_id"], name: "idx_metric_important_field_field_id"
    t.index ["metric_id", "field_id"], name: "unique_metric_important_field_metric_id_field_id", unique: true
    t.index ["metric_id"], name: "idx_metric_important_field_metric_id"
  end

  create_table "model_index", id: :integer, default: nil, comment: "Used to keep track of which models have indexed columns.", force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false, comment: "The timestamp of when these changes were made."
    t.integer "creator_id", null: false, comment: "ID of the user who created the event"
    t.text "error", comment: "The error message if the status is error."
    t.timestamptz "indexed_at", comment: "When the status changed"
    t.integer "model_id", comment: "The ID of the indexed model."
    t.text "pk_ref", null: false, comment: "Serialized JSON of the primary key field ref."
    t.text "schedule", null: false, comment: "The cron schedule for when value syncing should happen."
    t.text "state", null: false, comment: "The status of the index: initializing, indexed, error, overflow."
    t.text "value_ref", null: false, comment: "Serialized JSON of the label field ref."
    t.index ["model_id"], name: "idx_model_index_model_id"
  end

  create_table "model_index_value", id: false, comment: "Used to keep track of the values indexed in a model", force: :cascade do |t|
    t.integer "model_index_id", comment: "The ID of the indexed model."
    t.integer "model_pk", null: false, comment: "The primary key of the indexed value"
    t.text "name", null: false, comment: "The label to display identifying the indexed value."
    t.index ["model_index_id", "model_pk"], name: "unique_model_index_value_model_index_id_model_pk", unique: true
  end

  create_table "moderation_review", id: :integer, default: nil, comment: "Reviews (from moderators) for a given question/dashboard (BUCM)", force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false, comment: "creation time"
    t.integer "moderated_item_id", null: false, comment: "either a document or question ID; the item that needs review"
    t.string "moderated_item_type", limit: 255, null: false, comment: "whether it's a question or dashboard"
    t.integer "moderator_id", null: false, comment: "ID of the user who did the review"
    t.boolean "most_recent", null: false, comment: "tag for most recent review"
    t.string "status", limit: 255, comment: "verified, misleading, confusing, not_misleading, pending"
    t.text "text", comment: "Explanation of the review"
    t.timestamptz "updated_at", default: -> { "now()" }, null: false, comment: "most recent modification time"
    t.index ["moderated_item_type", "moderated_item_id"], name: "idx_moderation_review_item_type_item_id"
  end

  create_table "moneyman_users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "middle_name"
    t.string "passport"
    t.string "phone"
  end

  create_table "native_query_snippet", id: :integer, default: nil, comment: "Query snippets (raw text) to be substituted in native queries", force: :cascade do |t|
    t.boolean "archived", default: false, null: false
    t.integer "collection_id", comment: "ID of the Snippet Folder (Collection) this Snippet is in, if any"
    t.text "content", null: false, comment: "Raw query snippet"
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.integer "creator_id", null: false
    t.text "description"
    t.string "entity_id", limit: 21, comment: "Random NanoID tag for unique identity."
    t.string "name", limit: 254, null: false, comment: "Name of the query snippet"
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.index ["collection_id"], name: "idx_snippet_collection_id"
    t.index ["entity_id"], name: "native_query_snippet_entity_id_key", unique: true
    t.index ["name"], name: "idx_snippet_name"
    t.index ["name"], name: "native_query_snippet_name_key", unique: true
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

  create_table "otk_table_1", id: false, force: :cascade do |t|
    t.string "dob"
    t.string "femidav1"
    t.string "femidav2"
    t.string "fio"
    t.serial "id", null: false
    t.string "idx"
    t.string "phone"
    t.string "status"
  end

  create_table "parameter_card", id: :integer, default: nil, comment: "Join table connecting cards to entities (dashboards, other cards, etc.) that use the values generated by the card for filter values", force: :cascade do |t|
    t.integer "card_id", null: false, comment: "ID of the card generating the values"
    t.timestamptz "created_at", default: -> { "now()" }, null: false, comment: "creation time"
    t.string "entity_id", limit: 21, comment: "Random NanoID tag for unique identity."
    t.string "parameter_id", limit: 36, null: false, comment: "The parameter ID"
    t.integer "parameterized_object_id", null: false, comment: "ID of the entity consuming the values"
    t.string "parameterized_object_type", limit: 32, null: false, comment: "Type of the entity consuming the values (dashboard, card, etc.)"
    t.timestamptz "updated_at", default: -> { "now()" }, null: false, comment: "most recent modification time"
    t.index ["card_id"], name: "idx_parameter_card_card_id"
    t.index ["entity_id"], name: "parameter_card_entity_id_key", unique: true
    t.index ["parameterized_object_id", "parameterized_object_type", "parameter_id"], name: "unique_parameterized_object_card_parameter", unique: true
    t.index ["parameterized_object_id"], name: "idx_parameter_card_parameterized_object_id"
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

  create_table "permissions", id: :integer, default: nil, force: :cascade do |t|
    t.integer "group_id", null: false
    t.string "object", limit: 254, null: false
    t.index ["group_id", "object"], name: "idx_permissions_group_id_object"
    t.index ["group_id", "object"], name: "permissions_group_id_object_key", unique: true
    t.index ["group_id"], name: "idx_permissions_group_id"
    t.index ["object"], name: "idx_permissions_object"
  end

  create_table "permissions_group", id: :integer, default: nil, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.index ["name"], name: "idx_permissions_group_name"
    t.index ["name"], name: "unique_permissions_group_name", unique: true
  end

  create_table "permissions_group_membership", id: :integer, default: nil, force: :cascade do |t|
    t.integer "group_id", null: false
    t.boolean "is_group_manager", default: false, null: false, comment: "Boolean flag to indicate whether user is a group's manager."
    t.integer "user_id", null: false
    t.index ["group_id", "user_id"], name: "idx_permissions_group_membership_group_id_user_id"
    t.index ["group_id"], name: "idx_permissions_group_membership_group_id"
    t.index ["user_id", "group_id"], name: "unique_permissions_group_membership_user_id_group_id", unique: true
    t.index ["user_id"], name: "idx_permissions_group_membership_user_id"
  end

  create_table "permissions_revision", id: :integer, default: nil, comment: "Used to keep track of changes made to permissions.", force: :cascade do |t|
    t.text "after", null: false, comment: "Serialized JSON of the permissions after the changes."
    t.text "before", null: false, comment: "Serialized JSON of the permissions before the changes."
    t.datetime "created_at", precision: nil, null: false, comment: "The timestamp of when these changes were made."
    t.text "remark", comment: "Optional remarks explaining why these changes were made."
    t.integer "user_id", null: false, comment: "The ID of the admin who made this set of changes."
  end

  create_table "persisted_info", id: :integer, default: nil, comment: "Table holding information about persisted models", force: :cascade do |t|
    t.boolean "active", default: false, null: false, comment: "Indicating whether the persisted table is active and can be swapped"
    t.integer "card_id", null: false, comment: "ID of the Card model persisted"
    t.timestamptz "created_at", default: -> { "now()" }, null: false, comment: "The timestamp of when the model was first persisted"
    t.integer "creator_id", comment: "The person who persisted a model"
    t.integer "database_id", null: false, comment: "ID of the database associated to the persisted card"
    t.text "definition", comment: "JSON object that captures the state of the table when we persisted"
    t.text "error", comment: "Error message from persisting if applicable"
    t.text "query_hash", comment: "Hash of the query persisted"
    t.text "question_slug", null: false, comment: "Slug of the card which will form the persisted table name"
    t.timestamptz "refresh_begin", null: false, comment: "The timestamp of when the most recent refresh was started"
    t.timestamptz "refresh_end", comment: "The timestamp of when the most recent refresh ended"
    t.text "state", null: false, comment: "Persisted table state (creating, persisted, refreshing, deleted)"
    t.timestamptz "state_change_at", comment: "The timestamp of when the most recent state changed"
    t.text "table_name", null: false, comment: "Name of the table persisted"
    t.index ["card_id"], name: "persisted_info_card_id_key", unique: true
  end

  create_table "phone_rates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "phone"
    t.float "rate"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "pulse", id: :integer, default: nil, force: :cascade do |t|
    t.boolean "alert_above_goal", comment: "For a goal condition, alert when above the goal"
    t.string "alert_condition", limit: 254, comment: "Condition (i.e. \"rows\" or \"goal\") used as a guard for alerts"
    t.boolean "alert_first_only", comment: "True if the alert should be disabled after the first notification"
    t.boolean "archived", default: false, comment: "Has this pulse been archived?"
    t.integer "collection_id", comment: "Options ID of Collection this Pulse belongs to."
    t.integer "collection_position", limit: 2, comment: "Optional pinned position for this item in its Collection. NULL means item is not pinned."
    t.timestamptz "created_at", null: false
    t.integer "creator_id", null: false
    t.integer "dashboard_id", comment: "ID of the Dashboard if this Pulse is a Dashboard Subscription."
    t.string "entity_id", limit: 21, comment: "Random NanoID tag for unique identity."
    t.string "name", limit: 254
    t.text "parameters", null: false, comment: "Let dashboard subscriptions have their own filters"
    t.boolean "skip_if_empty", default: false, null: false, comment: "Skip a scheduled Pulse if none of its questions have any results"
    t.timestamptz "updated_at", null: false
    t.index ["collection_id"], name: "idx_pulse_collection_id"
    t.index ["creator_id"], name: "idx_pulse_creator_id"
    t.index ["entity_id"], name: "pulse_entity_id_key", unique: true
  end

  create_table "pulse_card", id: :integer, default: nil, force: :cascade do |t|
    t.integer "card_id", null: false
    t.integer "dashboard_card_id", comment: "If this Pulse is a Dashboard subscription, the ID of the DashboardCard that corresponds to this PulseCard."
    t.string "entity_id", limit: 21, comment: "Random NanoID tag for unique identity."
    t.boolean "include_csv", default: false, null: false, comment: "True if a CSV of the data should be included for this pulse card"
    t.boolean "include_xls", default: false, null: false, comment: "True if a XLS of the data should be included for this pulse card"
    t.integer "position", null: false
    t.integer "pulse_id", null: false
    t.index ["card_id"], name: "idx_pulse_card_card_id"
    t.index ["entity_id"], name: "pulse_card_entity_id_key", unique: true
    t.index ["pulse_id"], name: "idx_pulse_card_pulse_id"
  end

  create_table "pulse_channel", id: :integer, default: nil, force: :cascade do |t|
    t.string "channel_type", limit: 32, null: false
    t.timestamptz "created_at", null: false
    t.text "details", null: false
    t.boolean "enabled", default: true, null: false
    t.string "entity_id", limit: 21, comment: "Random NanoID tag for unique identity."
    t.integer "pulse_id", null: false
    t.string "schedule_day", limit: 64
    t.string "schedule_frame", limit: 32
    t.integer "schedule_hour"
    t.string "schedule_type", limit: 32, null: false
    t.timestamptz "updated_at", null: false
    t.index ["entity_id"], name: "pulse_channel_entity_id_key", unique: true
    t.index ["pulse_id"], name: "idx_pulse_channel_pulse_id"
    t.index ["schedule_type"], name: "idx_pulse_channel_schedule_type"
  end

  create_table "pulse_channel_recipient", id: :integer, default: nil, force: :cascade do |t|
    t.integer "pulse_channel_id", null: false
    t.integer "user_id", null: false
  end

  create_table "qrtz_blob_triggers", primary_key: ["sched_name", "trigger_name", "trigger_group"], comment: "Used for Quartz scheduler.", force: :cascade do |t|
    t.binary "blob_data"
    t.string "sched_name", limit: 120, null: false
    t.string "trigger_group", limit: 200, null: false
    t.string "trigger_name", limit: 200, null: false
  end

  create_table "qrtz_calendars", primary_key: ["sched_name", "calendar_name"], comment: "Used for Quartz scheduler.", force: :cascade do |t|
    t.binary "calendar", null: false
    t.string "calendar_name", limit: 200, null: false
    t.string "sched_name", limit: 120, null: false
  end

  create_table "qrtz_cron_triggers", primary_key: ["sched_name", "trigger_name", "trigger_group"], comment: "Used for Quartz scheduler.", force: :cascade do |t|
    t.string "cron_expression", limit: 120, null: false
    t.string "sched_name", limit: 120, null: false
    t.string "time_zone_id", limit: 80
    t.string "trigger_group", limit: 200, null: false
    t.string "trigger_name", limit: 200, null: false
  end

  create_table "qrtz_fired_triggers", primary_key: ["sched_name", "entry_id"], comment: "Used for Quartz scheduler.", force: :cascade do |t|
    t.string "entry_id", limit: 95, null: false
    t.bigint "fired_time", null: false
    t.string "instance_name", limit: 200, null: false
    t.boolean "is_nonconcurrent"
    t.string "job_group", limit: 200
    t.string "job_name", limit: 200
    t.integer "priority", null: false
    t.boolean "requests_recovery"
    t.string "sched_name", limit: 120, null: false
    t.bigint "sched_time"
    t.string "state", limit: 16, null: false
    t.string "trigger_group", limit: 200, null: false
    t.string "trigger_name", limit: 200, null: false
    t.index ["sched_name", "instance_name", "requests_recovery"], name: "idx_qrtz_ft_inst_job_req_rcvry"
    t.index ["sched_name", "instance_name"], name: "idx_qrtz_ft_trig_inst_name"
    t.index ["sched_name", "job_group"], name: "idx_qrtz_ft_jg"
    t.index ["sched_name", "job_name", "job_group"], name: "idx_qrtz_ft_j_g"
    t.index ["sched_name", "trigger_group"], name: "idx_qrtz_ft_tg"
    t.index ["sched_name", "trigger_name", "trigger_group"], name: "idx_qrtz_ft_t_g"
  end

  create_table "qrtz_job_details", primary_key: ["sched_name", "job_name", "job_group"], comment: "Used for Quartz scheduler.", force: :cascade do |t|
    t.string "description", limit: 250
    t.boolean "is_durable", null: false
    t.boolean "is_nonconcurrent", null: false
    t.boolean "is_update_data", null: false
    t.string "job_class_name", limit: 250, null: false
    t.binary "job_data"
    t.string "job_group", limit: 200, null: false
    t.string "job_name", limit: 200, null: false
    t.boolean "requests_recovery", null: false
    t.string "sched_name", limit: 120, null: false
    t.index ["sched_name", "job_group"], name: "idx_qrtz_j_grp"
    t.index ["sched_name", "requests_recovery"], name: "idx_qrtz_j_req_recovery"
  end

  create_table "qrtz_locks", primary_key: ["sched_name", "lock_name"], comment: "Used for Quartz scheduler.", force: :cascade do |t|
    t.string "lock_name", limit: 40, null: false
    t.string "sched_name", limit: 120, null: false
  end

  create_table "qrtz_paused_trigger_grps", primary_key: ["sched_name", "trigger_group"], comment: "Used for Quartz scheduler.", force: :cascade do |t|
    t.string "sched_name", limit: 120, null: false
    t.string "trigger_group", limit: 200, null: false
  end

  create_table "qrtz_scheduler_state", primary_key: ["sched_name", "instance_name"], comment: "Used for Quartz scheduler.", force: :cascade do |t|
    t.bigint "checkin_interval", null: false
    t.string "instance_name", limit: 200, null: false
    t.bigint "last_checkin_time", null: false
    t.string "sched_name", limit: 120, null: false
  end

  create_table "qrtz_simple_triggers", primary_key: ["sched_name", "trigger_name", "trigger_group"], comment: "Used for Quartz scheduler.", force: :cascade do |t|
    t.bigint "repeat_count", null: false
    t.bigint "repeat_interval", null: false
    t.string "sched_name", limit: 120, null: false
    t.bigint "times_triggered", null: false
    t.string "trigger_group", limit: 200, null: false
    t.string "trigger_name", limit: 200, null: false
  end

  create_table "qrtz_simprop_triggers", primary_key: ["sched_name", "trigger_name", "trigger_group"], comment: "Used for Quartz scheduler.", force: :cascade do |t|
    t.boolean "bool_prop_1"
    t.boolean "bool_prop_2"
    t.decimal "dec_prop_1", precision: 13, scale: 4
    t.decimal "dec_prop_2", precision: 13, scale: 4
    t.integer "int_prop_1"
    t.integer "int_prop_2"
    t.bigint "long_prop_1"
    t.bigint "long_prop_2"
    t.string "sched_name", limit: 120, null: false
    t.string "str_prop_1", limit: 512
    t.string "str_prop_2", limit: 512
    t.string "str_prop_3", limit: 512
    t.string "trigger_group", limit: 200, null: false
    t.string "trigger_name", limit: 200, null: false
  end

  create_table "qrtz_triggers", primary_key: ["sched_name", "trigger_name", "trigger_group"], comment: "Used for Quartz scheduler.", force: :cascade do |t|
    t.string "calendar_name", limit: 200
    t.string "description", limit: 250
    t.bigint "end_time"
    t.binary "job_data"
    t.string "job_group", limit: 200, null: false
    t.string "job_name", limit: 200, null: false
    t.integer "misfire_instr", limit: 2
    t.bigint "next_fire_time"
    t.bigint "prev_fire_time"
    t.integer "priority"
    t.string "sched_name", limit: 120, null: false
    t.bigint "start_time", null: false
    t.string "trigger_group", limit: 200, null: false
    t.string "trigger_name", limit: 200, null: false
    t.string "trigger_state", limit: 16, null: false
    t.string "trigger_type", limit: 8, null: false
    t.index ["sched_name", "calendar_name"], name: "idx_qrtz_t_c"
    t.index ["sched_name", "job_group"], name: "idx_qrtz_t_jg"
    t.index ["sched_name", "job_name", "job_group"], name: "idx_qrtz_t_j"
    t.index ["sched_name", "misfire_instr", "next_fire_time", "trigger_group", "trigger_state"], name: "idx_qrtz_t_nft_st_misfire_grp"
    t.index ["sched_name", "misfire_instr", "next_fire_time", "trigger_state"], name: "idx_qrtz_t_nft_st_misfire"
    t.index ["sched_name", "misfire_instr", "next_fire_time"], name: "idx_qrtz_t_nft_misfire"
    t.index ["sched_name", "next_fire_time"], name: "idx_qrtz_t_next_fire_time"
    t.index ["sched_name", "trigger_group", "trigger_state"], name: "idx_qrtz_t_n_g_state"
    t.index ["sched_name", "trigger_group"], name: "idx_qrtz_t_g"
    t.index ["sched_name", "trigger_name", "trigger_group", "trigger_state"], name: "idx_qrtz_t_n_state"
    t.index ["sched_name", "trigger_state", "next_fire_time"], name: "idx_qrtz_t_nft_st"
    t.index ["sched_name", "trigger_state"], name: "idx_qrtz_t_state"
  end

  create_table "query", primary_key: "query_hash", id: { type: :binary, comment: "The hash of the query dictionary. (This is a 256-bit SHA3 hash of the query dict.)" }, comment: "Information (such as average execution time) for different queries that have been previously ran.", force: :cascade do |t|
    t.integer "average_execution_time", null: false, comment: "Average execution time for the query, round to nearest number of milliseconds. This is updated as a rolling average."
    t.text "query", comment: "The actual \"query dictionary\" for this query."
  end

  create_table "query_action", primary_key: "action_id", id: { type: :integer, comment: "The related action", default: nil }, comment: "A readwrite query type of action", force: :cascade do |t|
    t.integer "database_id", null: false, comment: "The associated database"
    t.text "dataset_query", null: false, comment: "The MBQL writeback query"
  end

  create_table "query_cache", primary_key: "query_hash", id: { type: :binary, comment: "The hash of the query dictionary. (This is a 256-bit SHA3 hash of the query dict)." }, comment: "Cached results of queries are stored here when using the DB-based query cache.", force: :cascade do |t|
    t.binary "results", null: false, comment: "Cached, compressed results of running the query with the given hash."
    t.timestamptz "updated_at", null: false, comment: "The timestamp of when these query results were last refreshed."
    t.index ["updated_at"], name: "idx_query_cache_updated_at"
  end

  create_table "query_execution", id: :integer, default: nil, comment: "A log of executed queries, used for calculating historic execution times, auditing, and other purposes.", force: :cascade do |t|
    t.boolean "cache_hit", comment: "Cache hit on query execution"
    t.integer "card_id", comment: "The ID of the Card (Question) associated with this query execution, if any."
    t.string "context", limit: 32, comment: "Short string specifying how this query was executed, e.g. in a Dashboard or Pulse."
    t.integer "dashboard_id", comment: "The ID of the Dashboard associated with this query execution, if any."
    t.integer "database_id", comment: "ID of the database this query was ran against."
    t.text "error", comment: "Error message returned by failed query, if any."
    t.integer "executor_id", comment: "The ID of the User who triggered this query execution, if any."
    t.binary "hash", null: false, comment: "The hash of the query dictionary. This is a 256-bit SHA3 hash of the query."
    t.boolean "native", null: false, comment: "Whether the query was a native query, as opposed to an MBQL one (e.g., created with the GUI)."
    t.integer "pulse_id", comment: "The ID of the Pulse associated with this query execution, if any."
    t.integer "result_rows", null: false, comment: "Number of rows in the query results."
    t.integer "running_time", null: false, comment: "The time, in milliseconds, this query took to complete."
    t.timestamptz "started_at", null: false, comment: "Timestamp of when this query started running."
    t.index ["card_id", "started_at"], name: "idx_query_execution_card_id_started_at"
    t.index ["card_id"], name: "idx_query_execution_card_id"
    t.index ["context"], name: "idx_query_execution_context"
    t.index ["executor_id"], name: "idx_query_execution_executor_id"
    t.index ["hash", "started_at"], name: "idx_query_execution_query_hash_started_at"
    t.index ["started_at"], name: "idx_query_execution_started_at"
  end

  create_table "report_card", id: :integer, default: nil, force: :cascade do |t|
    t.boolean "archived", default: false, null: false
    t.integer "cache_ttl", comment: "The maximum time, in seconds, to return cached results for this Card rather than running a new query."
    t.integer "collection_id", comment: "Optional ID of Collection this Card belongs to."
    t.integer "collection_position", limit: 2, comment: "Optional pinned position for this item in its Collection. NULL means item is not pinned."
    t.boolean "collection_preview", default: true, null: false, comment: "Indicating whether the card should be visualized in the collection preview"
    t.timestamptz "created_at", null: false
    t.integer "creator_id", null: false
    t.integer "database_id", null: false
    t.boolean "dataset", default: false, null: false, comment: "Indicate whether question is a dataset"
    t.text "dataset_query", null: false
    t.text "description"
    t.string "display", limit: 254, null: false
    t.text "embedding_params", comment: "Serialized JSON containing information about required parameters that must be supplied when embedding this Card."
    t.boolean "enable_embedding", default: false, null: false, comment: "Is this Card allowed to be embedded in different websites (using a signed JWT)?"
    t.string "entity_id", limit: 21, comment: "Random NanoID tag for unique identity."
    t.integer "made_public_by_id", comment: "The ID of the User who first publically shared this Card."
    t.string "name", limit: 254, null: false
    t.text "parameter_mappings", comment: "List of parameter associated to a card"
    t.text "parameters", comment: "List of parameter associated to a card"
    t.string "public_uuid", limit: 36, comment: "Unique UUID used to in publically-accessible links to this Card."
    t.string "query_type", limit: 16
    t.text "result_metadata", comment: "Serialized JSON containing metadata about the result columns from running the query."
    t.integer "table_id"
    t.timestamptz "updated_at", null: false
    t.text "visualization_settings", null: false
    t.index ["collection_id"], name: "idx_card_collection_id"
    t.index ["creator_id"], name: "idx_card_creator_id"
    t.index ["entity_id"], name: "report_card_entity_id_key", unique: true
    t.index ["public_uuid"], name: "idx_card_public_uuid"
    t.index ["public_uuid"], name: "report_card_public_uuid_key", unique: true
  end

  create_table "report_cardfavorite", id: :integer, default: nil, force: :cascade do |t|
    t.integer "card_id", null: false
    t.timestamptz "created_at", null: false
    t.integer "owner_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["card_id", "owner_id"], name: "idx_unique_cardfavorite_card_id_owner_id", unique: true
    t.index ["card_id"], name: "idx_cardfavorite_card_id"
    t.index ["owner_id"], name: "idx_cardfavorite_owner_id"
  end

  create_table "report_dashboard", id: :integer, default: nil, force: :cascade do |t|
    t.boolean "archived", default: false, null: false, comment: "Is this Dashboard archived (effectively treated as deleted?)"
    t.boolean "auto_apply_filters", default: true, null: false, comment: "Whether or not to auto-apply filters on a dashboard"
    t.integer "cache_ttl", comment: "Granular cache TTL for specific dashboard."
    t.text "caveats"
    t.integer "collection_id", comment: "Optional ID of Collection this Dashboard belongs to."
    t.integer "collection_position", limit: 2, comment: "Optional pinned position for this item in its Collection. NULL means item is not pinned."
    t.timestamptz "created_at", null: false
    t.integer "creator_id", null: false
    t.text "description"
    t.text "embedding_params", comment: "Serialized JSON containing information about required parameters that must be supplied when embedding this Dashboard."
    t.boolean "enable_embedding", default: false, null: false, comment: "Is this Dashboard allowed to be embedded in different websites (using a signed JWT)?"
    t.string "entity_id", limit: 21, comment: "Random NanoID tag for unique identity."
    t.integer "made_public_by_id", comment: "The ID of the User who first publically shared this Dashboard."
    t.string "name", limit: 254, null: false
    t.text "parameters", null: false
    t.text "points_of_interest"
    t.integer "position", comment: "The position this Dashboard should appear in the Dashboards list, lower-numbered positions appearing before higher numbered ones."
    t.string "public_uuid", limit: 36, comment: "Unique UUID used to in publically-accessible links to this Dashboard."
    t.boolean "show_in_getting_started", default: false, null: false
    t.timestamptz "updated_at", null: false
    t.index ["collection_id"], name: "idx_dashboard_collection_id"
    t.index ["creator_id"], name: "idx_dashboard_creator_id"
    t.index ["entity_id"], name: "report_dashboard_entity_id_key", unique: true
    t.index ["public_uuid"], name: "idx_dashboard_public_uuid"
    t.index ["public_uuid"], name: "report_dashboard_public_uuid_key", unique: true
    t.index ["show_in_getting_started"], name: "idx_report_dashboard_show_in_getting_started"
  end

  create_table "report_dashboardcard", id: :integer, default: nil, force: :cascade do |t|
    t.integer "action_id", comment: "The related action"
    t.integer "card_id"
    t.integer "col", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.integer "dashboard_id", null: false
    t.integer "dashboard_tab_id", comment: "The referenced tab id that dashcard is on, it's nullable for dashboard with no tab"
    t.string "entity_id", limit: 21, comment: "Random NanoID tag for unique identity."
    t.text "parameter_mappings", null: false
    t.integer "row", null: false
    t.integer "size_x", null: false
    t.integer "size_y", null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.text "visualization_settings", null: false
    t.index ["card_id"], name: "idx_dashboardcard_card_id"
    t.index ["dashboard_id"], name: "idx_dashboardcard_dashboard_id"
    t.index ["entity_id"], name: "report_dashboardcard_entity_id_key", unique: true
  end

  create_table "requests", force: :cascade do |t|
    t.string "birth_date"
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "info"
    t.string "last_name"
    t.string "middle_name"
    t.string "phone"
    t.string "response"
    t.string "service"
    t.datetime "updated_at", null: false
    t.index ["phone"], name: "index_requests_on_phone"
  end

  create_table "retro_mc_femida_ext_complete_users", force: :cascade do |t|
    t.string "birth_date"
    t.string "first_name"
    t.string "info"
    t.string "last_name"
    t.string "middle_name"
    t.string "passport"
    t.string "passport_old"
    t.string "phone"
    t.string "phone_old"
  end

  create_table "retro_mc_femida_ext_users", force: :cascade do |t|
    t.string "birth_date"
    t.string "first_name"
    t.boolean "is_passport_verified"
    t.boolean "is_phone_verified"
    t.string "last_name"
    t.string "middle_name"
    t.string "passport"
    t.string "phone"
  end

  create_table "revision", id: :integer, default: nil, force: :cascade do |t|
    t.boolean "is_creation", default: false, null: false
    t.boolean "is_reversion", default: false, null: false
    t.text "message"
    t.string "model", limit: 16, null: false
    t.integer "model_id", null: false
    t.text "object", null: false
    t.timestamptz "timestamp", null: false
    t.integer "user_id", null: false
    t.index ["model", "model_id"], name: "idx_revision_model_model_id"
  end

  create_table "sample_01", force: :cascade do |t|
    t.string "birth_date"
    t.string "first_name"
    t.string "last_name"
    t.string "middle_name"
    t.string "phone"
    t.string "source"
    t.string "year"
    t.index ["phone"], name: "index_sample_01_on_phone"
  end

  create_table "sample_02", force: :cascade do |t|
    t.string "birth_date"
    t.integer "customer_id"
    t.string "first_name"
    t.string "info"
    t.boolean "is_passport_verified"
    t.boolean "is_phone_verified"
    t.string "last_name"
    t.string "middle_name"
    t.string "passport"
    t.string "phone"
    t.text "resp"
    t.index ["passport"], name: "index_sample_02_on_passport"
    t.index ["phone"], name: "index_sample_02_on_phone"
  end

  create_table "sandboxes", id: :integer, default: nil, comment: "Records that a given Card (Question) should automatically replace a given Table as query source for a given a Perms Group.", force: :cascade do |t|
    t.text "attribute_remappings", comment: "JSON-encoded map of user attribute identifier to the param name used in the Card."
    t.integer "card_id", comment: "ID of the Card (Question) to be used to replace the Table."
    t.integer "group_id", null: false, comment: "ID of the Permissions Group this policy affects."
    t.integer "permission_id", comment: "The ID of the corresponding permissions path for this sandbox"
    t.integer "table_id", null: false, comment: "ID of the Table that should get automatically replaced as query source for the Permissions Group."
    t.index ["table_id", "group_id"], name: "idx_gtap_table_id_group_id"
    t.index ["table_id", "group_id"], name: "unique_gtap_table_id_group_id", unique: true
  end

  create_table "secret", primary_key: ["id", "version"], comment: "Storage for managed secrets (passwords, binary data, etc.)", force: :cascade do |t|
    t.timestamptz "created_at", null: false, comment: "Timestamp for when this secret instance was created"
    t.integer "creator_id", comment: "User ID who created this secret instance"
    t.integer "id", null: false, comment: "Part of composite primary key for secret; this is the uniquely generted ID column"
    t.string "kind", limit: 254, null: false, comment: "The kind of secret this record represents; the value is interpreted as a Clojure keyword with a hierarchy. Ex: 'bytes' means generic binary data, 'jks-keystore' extends 'bytes' but has a specific meaning."
    t.string "name", limit: 254, null: false, comment: "The name of this secret record."
    t.string "source", limit: 254, comment: "The source of secret record, which controls how Metabase interprets the value (ex: 'file-path' means the 'simple_value' is not the real value, but a pointer to a file that contains the value)."
    t.timestamptz "updated_at", comment: "Timestamp for when this secret record was updated. Only relevant when non-value field changes since a value change will result in a new version being inserted."
    t.binary "value", null: false, comment: "The base64 encoded binary value of this secret record. If encryption is enabled, this will be the output of the encryption procedure on the plaintext. If not, it will be the base64 encoded plaintext."
    t.integer "version", default: 1, null: false, comment: "Part of composite primary key for secret; this is the version column"
  end

  create_table "segment", id: :integer, default: nil, force: :cascade do |t|
    t.boolean "archived", default: false, null: false
    t.text "caveats"
    t.timestamptz "created_at", null: false
    t.integer "creator_id", null: false
    t.text "definition", null: false
    t.text "description"
    t.string "entity_id", limit: 21, comment: "Random NanoID tag for unique identity."
    t.string "name", limit: 254, null: false
    t.text "points_of_interest"
    t.boolean "show_in_getting_started", default: false, null: false
    t.integer "table_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["creator_id"], name: "idx_segment_creator_id"
    t.index ["entity_id"], name: "segment_entity_id_key", unique: true
    t.index ["show_in_getting_started"], name: "idx_segment_show_in_getting_started"
    t.index ["table_id"], name: "idx_segment_table_id"
  end

  create_table "setting", primary_key: "key", id: { type: :string, limit: 254 }, force: :cascade do |t|
    t.text "value", null: false
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

  create_table "task_history", id: :integer, default: nil, comment: "Timing and metadata info about background/quartz processes", force: :cascade do |t|
    t.integer "db_id"
    t.integer "duration", null: false
    t.timestamptz "ended_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "started_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "task", limit: 254, null: false, comment: "Name of the task"
    t.text "task_details", comment: "JSON string with additional info on the task"
    t.index ["db_id"], name: "idx_task_history_db_id"
    t.index ["ended_at"], name: "idx_task_history_end_time"
  end

  create_table "terrorist_list", force: :cascade do |t|
    t.string "date_of_birth"
    t.string "first_name"
    t.string "last_name"
    t.string "middlename"
  end

  create_table "timeline", id: :integer, default: nil, comment: "Timeline table to organize events", force: :cascade do |t|
    t.boolean "archived", default: false, null: false, comment: "Whether or not the timeline has been archived"
    t.integer "collection_id", comment: "ID of the collection containing the timeline"
    t.timestamptz "created_at", default: -> { "now()" }, null: false, comment: "The timestamp of when the timeline was created"
    t.integer "creator_id", null: false, comment: "ID of the user who created the timeline"
    t.boolean "default", default: false, null: false, comment: "Boolean value indicating if the timeline is the default one for the containing Collection"
    t.string "description", limit: 255, comment: "Optional description of the timeline"
    t.string "entity_id", limit: 21, comment: "Random NanoID tag for unique identity."
    t.string "icon", limit: 128, null: false, comment: "the icon to use when displaying the event"
    t.string "name", limit: 255, null: false, comment: "Name of the timeline"
    t.timestamptz "updated_at", default: -> { "now()" }, null: false, comment: "The timestamp of when the timeline was updated"
    t.index ["collection_id"], name: "idx_timeline_collection_id"
    t.index ["entity_id"], name: "timeline_entity_id_key", unique: true
  end

  create_table "timeline_event", id: :integer, default: nil, comment: "Events table", force: :cascade do |t|
    t.boolean "archived", default: false, null: false, comment: "Whether or not the event has been archived"
    t.timestamptz "created_at", default: -> { "now()" }, null: false, comment: "The timestamp of when the event was created"
    t.integer "creator_id", null: false, comment: "ID of the user who created the event"
    t.string "description", limit: 255, comment: "Optional markdown description of the event"
    t.string "icon", limit: 128, null: false, comment: "the icon to use when displaying the event"
    t.string "name", limit: 255, null: false, comment: "Name of the event"
    t.boolean "time_matters", null: false, comment: "Indicate whether the time component matters or if the timestamp should just serve to indicate the day of the event without any time associated to it."
    t.integer "timeline_id", null: false, comment: "ID of the timeline containing the event"
    t.timestamptz "timestamp", null: false, comment: "When the event happened"
    t.string "timezone", limit: 255, null: false, comment: "Timezone to display the underlying UTC timestamp in for the client"
    t.timestamptz "updated_at", default: -> { "now()" }, null: false, comment: "The timestamp of when the event was modified"
    t.index ["timeline_id", "timestamp"], name: "idx_timeline_event_timeline_id_timestamp"
    t.index ["timeline_id"], name: "idx_timeline_event_timeline_id"
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
    t.boolean "is_passport_verified_2"
    t.string "is_pdl"
    t.string "is_phone_verified"
    t.boolean "is_phone_verified_2"
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

  create_table "user_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "role"
    t.integer "role_id"
    t.datetime "updated_at", null: false
    t.integer "user_id"
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

  create_table "view_log", id: :integer, default: nil, force: :cascade do |t|
    t.text "metadata", comment: "Serialized JSON corresponding to metadata for view."
    t.string "model", limit: 16, null: false
    t.integer "model_id", null: false
    t.timestamptz "timestamp", null: false
    t.integer "user_id"
    t.index ["model_id"], name: "idx_view_log_timestamp"
    t.index ["user_id"], name: "idx_view_log_user_id"
  end

  add_foreign_key "action", "core_user", column: "creator_id", name: "fk_action_creator_id"
  add_foreign_key "action", "core_user", column: "made_public_by_id", name: "fk_action_made_public_by_id", on_delete: :cascade
  add_foreign_key "action", "report_card", column: "model_id", name: "fk_action_model_id", on_delete: :cascade
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity", "core_user", column: "user_id", name: "fk_activity_ref_user_id", on_delete: :cascade
  add_foreign_key "application_permissions_revision", "core_user", column: "user_id", name: "fk_general_permissions_revision_user_id"
  add_foreign_key "authorizations", "users"
  add_foreign_key "bookmark_ordering", "core_user", column: "user_id", name: "fk_bookmark_ordering_user_id", on_delete: :cascade
  add_foreign_key "card_bookmark", "core_user", column: "user_id", name: "fk_card_bookmark_user_id", on_delete: :cascade
  add_foreign_key "card_bookmark", "report_card", column: "card_id", name: "fk_card_bookmark_dashboard_id", on_delete: :cascade
  add_foreign_key "card_label", "label", name: "fk_card_label_ref_label_id", on_delete: :cascade
  add_foreign_key "card_label", "report_card", column: "card_id", name: "fk_card_label_ref_card_id", on_delete: :cascade
  add_foreign_key "collection", "core_user", column: "personal_owner_id", name: "fk_collection_personal_owner_id", on_delete: :cascade
  add_foreign_key "collection_bookmark", "collection", name: "fk_collection_bookmark_collection_id", on_delete: :cascade
  add_foreign_key "collection_bookmark", "core_user", column: "user_id", name: "fk_collection_bookmark_user_id", on_delete: :cascade
  add_foreign_key "collection_permission_graph_revision", "core_user", column: "user_id", name: "fk_collection_revision_user_id", on_delete: :cascade
  add_foreign_key "computation_job", "core_user", column: "creator_id", name: "fk_computation_job_ref_user_id", on_delete: :cascade
  add_foreign_key "computation_job_result", "computation_job", column: "job_id", name: "fk_computation_result_ref_job_id", on_delete: :cascade
  add_foreign_key "connection_impersonations", "metabase_database", column: "db_id", name: "fk_conn_impersonation_db_id", on_delete: :cascade
  add_foreign_key "connection_impersonations", "permissions_group", column: "group_id", name: "fk_conn_impersonation_group_id", on_delete: :cascade
  add_foreign_key "core_session", "core_user", column: "user_id", name: "fk_session_ref_user_id", on_delete: :cascade
  add_foreign_key "dashboard_bookmark", "core_user", column: "user_id", name: "fk_dashboard_bookmark_user_id", on_delete: :cascade
  add_foreign_key "dashboard_bookmark", "report_dashboard", column: "dashboard_id", name: "fk_dashboard_bookmark_dashboard_id", on_delete: :cascade
  add_foreign_key "dashboard_favorite", "core_user", column: "user_id", name: "fk_dashboard_favorite_user_id", on_delete: :cascade
  add_foreign_key "dashboard_favorite", "report_dashboard", column: "dashboard_id", name: "fk_dashboard_favorite_dashboard_id", on_delete: :cascade
  add_foreign_key "dashboard_tab", "report_dashboard", column: "dashboard_id", name: "fk_dashboard_tab_ref_dashboard_id", on_delete: :cascade
  add_foreign_key "dashboardcard_series", "report_card", column: "card_id", name: "fk_dashboardcard_series_ref_card_id", on_delete: :cascade
  add_foreign_key "dashboardcard_series", "report_dashboardcard", column: "dashboardcard_id", name: "fk_dashboardcard_series_ref_dashboardcard_id", on_delete: :cascade
  add_foreign_key "dimension", "metabase_field", column: "field_id", name: "fk_dimension_ref_field_id", on_delete: :cascade
  add_foreign_key "dimension", "metabase_field", column: "human_readable_field_id", name: "fk_dimension_displayfk_ref_field_id", on_delete: :cascade
  add_foreign_key "http_action", "action", name: "fk_http_action_ref_action_id", on_delete: :cascade
  add_foreign_key "implicit_action", "action", name: "fk_implicit_action_action_id", on_delete: :cascade
  add_foreign_key "login_history", "core_session", column: "session_id", name: "fk_login_history_session_id", on_delete: :nullify
  add_foreign_key "login_history", "core_user", column: "user_id", name: "fk_login_history_user_id", on_delete: :cascade
  add_foreign_key "metabase_database", "core_user", column: "creator_id", name: "fk_database_creator_id", on_delete: :nullify
  add_foreign_key "metabase_field", "metabase_field", column: "parent_id", name: "fk_field_parent_ref_field_id", on_delete: :cascade
  add_foreign_key "metabase_field", "metabase_table", column: "table_id", name: "fk_field_ref_table_id", on_delete: :cascade
  add_foreign_key "metabase_fieldvalues", "metabase_field", column: "field_id", name: "fk_fieldvalues_ref_field_id", on_delete: :cascade
  add_foreign_key "metabase_table", "metabase_database", column: "db_id", name: "fk_table_ref_database_id", on_delete: :cascade
  add_foreign_key "metric", "core_user", column: "creator_id", name: "fk_metric_ref_creator_id", on_delete: :cascade
  add_foreign_key "metric", "metabase_table", column: "table_id", name: "fk_metric_ref_table_id", on_delete: :cascade
  add_foreign_key "metric_important_field", "metabase_field", column: "field_id", name: "fk_metric_important_field_metabase_field_id", on_delete: :cascade
  add_foreign_key "metric_important_field", "metric", name: "fk_metric_important_field_metric_id", on_delete: :cascade
  add_foreign_key "model_index", "core_user", column: "creator_id", name: "fk_model_index_creator_id", on_delete: :cascade
  add_foreign_key "model_index", "report_card", column: "model_id", name: "fk_model_index_model_id", on_delete: :cascade
  add_foreign_key "model_index_value", "model_index", name: "fk_model_index_value_model_id", on_delete: :cascade
  add_foreign_key "native_query_snippet", "collection", name: "fk_snippet_collection_id", on_delete: :nullify
  add_foreign_key "native_query_snippet", "core_user", column: "creator_id", name: "fk_snippet_creator_id", on_delete: :cascade
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "parameter_card", "report_card", column: "card_id", name: "fk_parameter_card_ref_card_id", on_delete: :cascade
  add_foreign_key "permissions", "permissions_group", column: "group_id", name: "fk_permissions_group_id", on_delete: :cascade
  add_foreign_key "permissions_group_membership", "core_user", column: "user_id", name: "fk_permissions_group_membership_user_id", on_delete: :cascade
  add_foreign_key "permissions_group_membership", "permissions_group", column: "group_id", name: "fk_permissions_group_group_id", on_delete: :cascade
  add_foreign_key "permissions_revision", "core_user", column: "user_id", name: "fk_permissions_revision_user_id", on_delete: :cascade
  add_foreign_key "persisted_info", "core_user", column: "creator_id", name: "fk_persisted_info_ref_creator_id"
  add_foreign_key "persisted_info", "metabase_database", column: "database_id", name: "fk_persisted_info_database_id", on_delete: :cascade
  add_foreign_key "persisted_info", "report_card", column: "card_id", name: "fk_persisted_info_card_id", on_delete: :cascade
  add_foreign_key "pulse", "collection", name: "fk_pulse_collection_id", on_delete: :nullify
  add_foreign_key "pulse", "core_user", column: "creator_id", name: "fk_pulse_ref_creator_id", on_delete: :cascade
  add_foreign_key "pulse", "report_dashboard", column: "dashboard_id", name: "fk_pulse_ref_dashboard_id", on_delete: :cascade
  add_foreign_key "pulse_card", "pulse", name: "fk_pulse_card_ref_pulse_id", on_delete: :cascade
  add_foreign_key "pulse_card", "report_card", column: "card_id", name: "fk_pulse_card_ref_card_id", on_delete: :cascade
  add_foreign_key "pulse_card", "report_dashboardcard", column: "dashboard_card_id", name: "fk_pulse_card_ref_pulse_card_id", on_delete: :cascade
  add_foreign_key "pulse_channel", "pulse", name: "fk_pulse_channel_ref_pulse_id", on_delete: :cascade
  add_foreign_key "pulse_channel_recipient", "core_user", column: "user_id", name: "fk_pulse_channel_recipient_ref_user_id", on_delete: :cascade
  add_foreign_key "pulse_channel_recipient", "pulse_channel", name: "fk_pulse_channel_recipient_ref_pulse_channel_id", on_delete: :cascade
  add_foreign_key "qrtz_blob_triggers", "qrtz_triggers", column: "sched_name", primary_key: "sched_name", name: "fk_qrtz_blob_triggers_triggers"
  add_foreign_key "qrtz_cron_triggers", "qrtz_triggers", column: "sched_name", primary_key: "sched_name", name: "fk_qrtz_cron_triggers_triggers"
  add_foreign_key "qrtz_simple_triggers", "qrtz_triggers", column: "sched_name", primary_key: "sched_name", name: "fk_qrtz_simple_triggers_triggers"
  add_foreign_key "qrtz_simprop_triggers", "qrtz_triggers", column: "sched_name", primary_key: "sched_name", name: "fk_qrtz_simprop_triggers_triggers"
  add_foreign_key "qrtz_triggers", "qrtz_job_details", column: "sched_name", primary_key: "sched_name", name: "fk_qrtz_triggers_job_details"
  add_foreign_key "query_action", "action", name: "fk_query_action_ref_action_id", on_delete: :cascade
  add_foreign_key "query_action", "metabase_database", column: "database_id", name: "fk_query_action_database_id", on_delete: :cascade
  add_foreign_key "report_card", "collection", name: "fk_card_collection_id", on_delete: :nullify
  add_foreign_key "report_card", "core_user", column: "creator_id", name: "fk_card_ref_user_id", on_delete: :cascade
  add_foreign_key "report_card", "core_user", column: "made_public_by_id", name: "fk_card_made_public_by_id", on_delete: :cascade
  add_foreign_key "report_card", "metabase_database", column: "database_id", name: "fk_report_card_ref_database_id", on_delete: :cascade
  add_foreign_key "report_card", "metabase_table", column: "table_id", name: "fk_report_card_ref_table_id", on_delete: :cascade
  add_foreign_key "report_cardfavorite", "core_user", column: "owner_id", name: "fk_cardfavorite_ref_user_id", on_delete: :cascade
  add_foreign_key "report_cardfavorite", "report_card", column: "card_id", name: "fk_cardfavorite_ref_card_id", on_delete: :cascade
  add_foreign_key "report_dashboard", "collection", name: "fk_dashboard_collection_id", on_delete: :nullify
  add_foreign_key "report_dashboard", "core_user", column: "creator_id", name: "fk_dashboard_ref_user_id", on_delete: :cascade
  add_foreign_key "report_dashboard", "core_user", column: "made_public_by_id", name: "fk_dashboard_made_public_by_id", on_delete: :cascade
  add_foreign_key "report_dashboardcard", "action", name: "fk_report_dashboardcard_ref_action_id", on_delete: :cascade
  add_foreign_key "report_dashboardcard", "dashboard_tab", name: "fk_report_dashboardcard_ref_dashboard_tab_id", on_delete: :cascade
  add_foreign_key "report_dashboardcard", "report_card", column: "card_id", name: "fk_dashboardcard_ref_card_id", on_delete: :cascade
  add_foreign_key "report_dashboardcard", "report_dashboard", column: "dashboard_id", name: "fk_dashboardcard_ref_dashboard_id", on_delete: :cascade
  add_foreign_key "revision", "core_user", column: "user_id", name: "fk_revision_ref_user_id", on_delete: :cascade
  add_foreign_key "sandboxes", "metabase_table", column: "table_id", name: "fk_gtap_table_id", on_delete: :cascade
  add_foreign_key "sandboxes", "permissions", name: "fk_sandboxes_ref_permissions", on_delete: :cascade
  add_foreign_key "sandboxes", "permissions_group", column: "group_id", name: "fk_gtap_group_id", on_delete: :cascade
  add_foreign_key "sandboxes", "report_card", column: "card_id", name: "fk_gtap_card_id", on_delete: :cascade
  add_foreign_key "secret", "core_user", column: "creator_id", name: "fk_secret_ref_user_id"
  add_foreign_key "segment", "core_user", column: "creator_id", name: "fk_segment_ref_creator_id", on_delete: :cascade
  add_foreign_key "segment", "metabase_table", column: "table_id", name: "fk_segment_ref_table_id", on_delete: :cascade
  add_foreign_key "timeline", "collection", name: "fk_timeline_collection_id", on_delete: :cascade
  add_foreign_key "timeline", "core_user", column: "creator_id", name: "fk_timeline_creator_id", on_delete: :cascade
  add_foreign_key "timeline_event", "core_user", column: "creator_id", name: "fk_event_creator_id", on_delete: :cascade
  add_foreign_key "timeline_event", "timeline", name: "fk_events_timeline_id", on_delete: :cascade
  add_foreign_key "view_log", "core_user", column: "user_id", name: "fk_view_log_ref_user_id", on_delete: :cascade
end
