# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170326233208) do

  create_table "photo_files", force: :cascade do |t|
    t.string   "ftype",      null: false
    t.text     "path",       null: false
    t.integer  "photo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "width"
    t.integer  "height"
    t.index ["photo_id", "ftype"], name: "index_photo_files_on_photo_id_and_ftype", unique: true
  end

  create_table "photos", force: :cascade do |t|
    t.integer  "rating"
    t.string   "imageable_type"
    t.integer  "imageable_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.text     "exif_json"
    t.integer  "view_phi"
    t.integer  "view_lambda"
    t.text     "description"
    t.string   "state"
    t.string   "ptype"
    t.string   "source"
    t.string   "camera"
    t.index ["imageable_type", "imageable_id"], name: "index_photos_on_imageable_type_and_imageable_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "sites", force: :cascade do |t|
    t.text     "notes"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.float    "horizontal_error"
    t.float    "altitude"
    t.float    "temperature"
    t.text     "weather"
    t.text     "collector"
    t.string   "sample_type"
    t.string   "transect"
    t.integer  "duration"
    t.datetime "started_at"
    t.text     "description"
    t.integer  "project_id"
    t.string   "ref"
    t.index ["project_id"], name: "index_sites_on_project_id"
  end

  create_table "specimens", force: :cascade do |t|
    t.text     "description"
    t.text     "species"
    t.integer  "site_id"
    t.integer  "quantity"
    t.float    "body_length"
    t.text     "notes"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "taxon_id"
    t.string   "id_confidence"
    t.string   "other"
    t.string   "ref"
    t.string   "disposition"
    t.string   "form"
    t.string   "sex"
    t.index ["site_id"], name: "index_specimens_on_site_id"
    t.index ["taxon_id"], name: "index_specimens_on_taxon_id"
  end

  create_table "taxa", force: :cascade do |t|
    t.text     "description"
    t.text     "scientific_name"
    t.text     "common_name"
    t.integer  "parent_taxon_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.text     "rank"
    t.string   "authority"
    t.index ["parent_taxon_id"], name: "index_taxa_on_parent_taxon_id"
  end

end
