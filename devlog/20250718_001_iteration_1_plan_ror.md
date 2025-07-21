
# Echoes of Korea: Iteration 1 Plan (Ruby on Rails)

## 1. Project Overview

This document outlines the plan for the first iteration of the "Echoes of Korea" project, implemented using Ruby on Rails. The primary goal is to build a secure, internal-facing web application for a super-admin to manage the lifecycle of oral history recordings, from upload to transcription and preparation for future analysis.

## 2. Core Features

The focus remains on creating a robust and efficient workflow for the administrator.

*   **Secure Admin Access:**
    *   A dedicated login page for the administrator.
    *   Access to the admin panel will be restricted to authenticated users.
*   **Interview Management:**
    *   A dashboard to view all uploaded interview recordings.
    *   The ability to upload new audio files.
    *   A form to add and edit metadata for each interview (e.g., interviewee name, birth year, title).
*   **One-Click STT (Speech-to-Text):**
    *   A button to trigger the transcription process for an uploaded audio file.
    *   The system will handle the process asynchronously in the background using Active Job.
    *   The status of the transcription (`processing`, `completed`, `failed`) will be displayed in the UI.
*   **Transcript Management:**
    *   Once transcription is complete, the full text will be displayed.
    *   The administrator will be able to view and edit the generated transcript for accuracy.
*   **LLM-Ready Architecture:**
    *   The system will be designed to easily integrate with Large Language Models (LLMs) in the future for tasks like summarization, keyword extraction, and sentiment analysis.

## 3. Technology Stack

*   **Framework:** Ruby on Rails 7+
*   **Language:** Ruby 3+
*   **Database:** PostgreSQL (via Active Record)
*   **Frontend:** ERB (Embedded Ruby) for templating, Hotwire (Turbo, Stimulus) for dynamic UI
*   **File Storage:** Active Storage (configured for local disk initially, easily extendable to AWS S3/GCS)
*   **Authentication:** Devise Gem
*   **Background Jobs:** Active Job (with Sidekiq or similar for production)
*   **External Services:**
    *   **STT:** HTTP client (e.g., Faraday, HTTParty) to Naver CLOVA Speech API
    *   **LLM:** HTTP client to OpenAI GPT series API (for future integration)
*   **Deployment:** Docker, Heroku, or other Rails-compatible PaaS

## 4. Database Schema (Active Record / PostgreSQL)

A single table will be used to manage the interviews.

### `interviews` Table

```ruby
# db/migrate/YYYYMMDDHHMMSS_create_interviews.rb
class CreateInterviews < ActiveRecord::Migration[7.x]
  def change
    create_table :interviews, id: :uuid do |t|
      t.string :interviewee_name
      t.integer :interviewee_birth_year
      t.date :interview_date
      t.string :title
      t.string :stt_status, default: 'not_started' # 'not_started', 'processing', 'completed', 'failed'
      t.text :full_transcript
      t.jsonb :llm_summary # For future multilingual summaries
      t.boolean :is_published, default: false

      t.timestamps # created_at and updated_at
    end

    # Add Active Storage for audio file
    add_reference :interviews, :audio_file_blob, foreign_key: { to_table: :active_storage_blobs }, type: :uuid, index: true
  end
end
```

**Notes:**
*   `id: :uuid` for UUID primary keys (requires `uuid-ossp` extension in PostgreSQL).
*   `t.timestamps` automatically adds `created_at` and `updated_at` (datetime).
*   `Active Storage` handles file attachments. The `audio_file_blob` reference is conceptual; Active Storage manages associations automatically.

## 5. API Endpoints (Rails Routes & Controllers)

Rails follows RESTful conventions. These will be handled by controllers.

### 5.1. Authentication

*   **Login:** Handled by Devise (e.g., `POST /users/sign_in`).
*   **Logout:** Handled by Devise (e.g., `DELETE /users/sign_out`).

### 5.2. Interview Management

*   **Dashboard:** `GET /admin/dashboard` (AdminController#dashboard)
*   **List Interviews:** `GET /admin/interviews` (InterviewsController#index)
*   **Show Interview:** `GET /admin/interviews/:id` (InterviewsController#show)
*   **New Interview Form:** `GET /admin/interviews/new` (InterviewsController#new)
*   **Create Interview:** `POST /admin/interviews` (InterviewsController#create)
    *   Handles metadata and audio file upload (via Active Storage).
*   **Edit Interview Form:** `GET /admin/interviews/:id/edit` (InterviewsController#edit)
*   **Update Interview:** `PATCH/PUT /admin/interviews/:id` (InterviewsController#update)

### 5.3. STT Processing

*   **Initiate STT:** `POST /admin/interviews/:id/transcribe` (InterviewsController#transcribe)
    *   **Action:** Enqueues a background job (e.g., `TranscribeAudioJob.perform_later(interview.id)`).
*   **STT Webhook:** `POST /api/stt-webhook` (WebhookController#stt_callback)
    *   **Description:** Endpoint for the external STT service to call when transcription is complete.
    *   **Action:** Receives the transcript, updates the `Interview` record, and sets `stt_status` to `completed`.

## 6. Directory Structure (Standard Rails Application)

```
/echoes_of_korea
├── app/
│   ├── assets/             # CSS, JavaScript, images
│   ├── channels/           # Action Cable websockets
│   ├── controllers/        # Application logic for HTTP requests
│   │   ├── admin/          # Admin-specific controllers
│   │   │   └── dashboard_controller.rb
│   │   ├── interviews_controller.rb
│   │   └── webhook_controller.rb
│   ├── helpers/            # View helpers
│   ├── jobs/               # Active Job background jobs
│   │   └── transcribe_audio_job.rb
│   ├── mailers/            # Email sending
│   ├── models/             # Active Record models
│   │   ├── user.rb         # Devise user model
│   │   └── interview.rb
│   └── views/              # ERB templates
│       ├── admin/
│       │   └── dashboard/
│       │       └── index.html.erb
│       ├── interviews/
│       │   ├── index.html.erb
│       │   ├── show.html.erb
│       │   ├── new.html.erb
│       │   └── edit.html.erb
│       └── layouts/
│           └── application.html.erb
├── bin/                    # Rails executables
├── config/                 # Application configuration
│   ├── environments/
│   ├── initializers/
│   ├── locales/            # i18n translation files (e.g., en.yml, ko.yml)
│   └── routes.rb           # Defines application routes
├── db/                     # Database schema and migrations
│   └── migrate/
├── lib/                    # Custom libraries (e.g., STT client)
├── log/                    # Application logs
├── public/                 # Static files
├── storage/                # Active Storage local files
├── test/                   # Tests
├── tmp/                    # Temporary files
├── vendor/                 # Third-party code
├── .gitignore
├── Gemfile                 # RubyGems dependencies
├── Gemfile.lock
├── Rakefile                # Rake tasks
└── README.md
```
