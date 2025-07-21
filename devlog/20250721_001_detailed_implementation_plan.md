# Echoes of Korea: Detailed Implementation Plan for Q&A Interview System

## 1. 개요

본 문서는 "Echoes of Korea" 프로젝트의 Q&A 기반 인터뷰 시스템 구현을 위한 상세한 단계별 계획을 제시합니다. 기존의 단일 인터뷰 모델에서 벗어나, 재사용 가능한 인터뷰 템플릿, 구조화된 인터뷰 세션, 그리고 개별 답변 추적(각 답변에 대한 오디오 및 STT 스크립트 포함)을 도입하여 시스템의 유연성, 확장성 및 사용자 경험을 향상시키는 데 중점을 둡니다.

## 2. 상세 구현 계획

### 2.1. 데이터베이스 스키마 구현 (Rails Migrations)

새로운 Q&A 기반 시스템을 위한 핵심 데이터 모델을 정의하고 마이그레이션을 생성합니다.

*   **UUID 확장 활성화:**
    *   `db/migrate/YYYYMMDDHHMMSS_enable_uuid_ossp_extension.rb` 파일을 생성하여 PostgreSQL의 `uuid-ossp` 확장을 활성화합니다.
    ```ruby
    # db/migrate/YYYYMMDDHHMMSS_enable_uuid_ossp_extension.rb
    class EnableUuidOsspExtension < ActiveRecord::Migration[7.x]
      def change
        enable_extension 'uuid-ossp'
      end
    end
    ```
*   **`interview_templates` 테이블 생성:**
    *   재사용 가능한 질문 템플릿을 관리합니다.
    ```ruby
    # db/migrate/YYYYMMDDHHMMSS_create_interview_templates.rb
    class CreateInterviewTemplates < ActiveRecord::Migration[7.x]
      def change
        create_table :interview_templates, id: :uuid do |t|
          t.string :template_name, null: false
          t.text :description
          t.references :created_by, type: :uuid, foreign_key: { to_table: :users } # Assuming User model exists
          t.timestamps
        end
        add_index :interview_templates, :template_name, unique: true
      end
    end
    ```
*   **`template_questions` 테이블 생성:**
    *   각 템플릿에 속하는 개별 질문을 저장합니다.
    ```ruby
    # db/migrate/YYYYMMDDHHMMSS_create_template_questions.rb
    class CreateTemplateQuestions < ActiveRecord::Migration[7.x]
      def change
        create_table :template_questions, id: :uuid do |t|
          t.references :interview_template, type: :uuid, null: false, foreign_key: true
          t.text :question_text, null: false
          t.integer :display_order, null: false
          t.integer :estimated_time_seconds
          t.timestamps
        end
        add_index :template_questions, [:interview_template_id, :display_order], unique: true
      end
    end
    ```
*   **`interviews` 테이블 생성:**
    *   인터뷰 대상자와 진행되는 단일 인터뷰 세션을 나타냅니다.
    ```ruby
    # db/migrate/YYYYMMDDHHMMSS_create_interviews.rb
    class CreateInterviews < ActiveRecord::Migration[7.x]
      def change
        create_table :interviews, id: :uuid do |t|
          t.string :interviewee_name, null: false
          t.string :interviewee_email
          t.string :status, null: false, default: 'pending' # 'pending', 'in_progress', 'completed', 'expired'
          t.references :created_from_template, type: :uuid, foreign_key: { to_table: :interview_templates }
          t.string :unique_link_id, null: false, index: { unique: true }
          t.timestamps
        end
      end
    end
    ```
*   **`interview_questions` 테이블 생성:**
    *   특정 인터뷰 세션의 질문 스냅샷을 저장합니다. (템플릿 변경에 영향을 받지 않도록 비정규화)
    ```ruby
    # db/migrate/YYYYMMDDHHMMSS_create_interview_questions.rb
    class CreateInterviewQuestions < ActiveRecord::Migration[7.x]
      def change
        create_table :interview_questions, id: :uuid do |t|
          t.references :interview, type: :uuid, null: false, foreign_key: true
          t.text :question_text, null: false
          t.integer :display_order, null: false
          t.timestamps
        end
        add_index :interview_questions, [:interview_id, :display_order], unique: true
      end
    end
    ```
*   **`answers` 테이블 생성:**
    *   인터뷰 대상자의 개별 답변을 저장합니다.
    ```ruby
    # db/migrate/YYYYMMDDHHMMSS_create_answers.rb
    class CreateAnswers < ActiveRecord::Migration[7.x]
      def change
        create_table :answers, id: :uuid do |t|
          t.references :interview_question, type: :uuid, null: false, foreign_key: true
          t.string :stt_status, null: false, default: 'pending' # 'pending', 'processing', 'completed', 'failed'
          t.jsonb :transcript_result # Full JSON response from STT service
          t.timestamps
        end
      end
    end
    ```
*   **Active Storage 설정:**
    *   `answers` 테이블에 오디오 파일 첨부를 위한 Active Storage를 설정합니다. `Answer` 모델에 `has_one_attached :audio_file`을 추가합니다.

### 2.2. 모델 정의 (Active Record Models)

각 테이블에 해당하는 Rails 모델을 정의하고 관계를 설정합니다.

*   **`app/models/user.rb` (Devise 연동):**
    ```ruby
    # app/models/user.rb
    class User < ApplicationRecord
      # Include default devise modules. Others available are:
      # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
      devise :database_authenticatable, :registerable,
             :recoverable, :rememberable, :validatable

      has_many :created_interview_templates, class_name: 'InterviewTemplate', foreign_key: 'created_by_id'

      # Add a role or admin flag if not using a separate role management gem
      # enum role: { user: 0, admin: 1 }
      # after_initialize :set_default_role, if: :new_record?
      # private
      # def set_default_role
      #   self.role ||= :user
      # end
    end
    ```
*   **`app/models/interview_template.rb`:**
    ```ruby
    # app/models/interview_template.rb
    class InterviewTemplate < ApplicationRecord
      has_many :template_questions, dependent: :destroy
      belongs_to :created_by, class_name: 'User', optional: true # Optional if admin user is not strictly required for template creation initially
      has_many :interviews, foreign_key: 'created_from_template_id', dependent: :nullify

      validates :template_name, presence: true, uniqueness: true

      accepts_nested_attributes_for :template_questions, allow_destroy: true
    end
    ```
*   **`app/models/template_question.rb`:**
    ```ruby
    # app/models/template_question.rb
    class TemplateQuestion < ApplicationRecord
      belongs_to :interview_template

      validates :question_text, presence: true
      validates :display_order, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :display_order, uniqueness: { scope: :interview_template_id }

      default_scope { order(:display_order) }
    end
    ```
*   **`app/models/interview.rb`:**
    ```ruby
    # app/models/interview.rb
    class Interview < ApplicationRecord
      belongs_to :created_from_template, class_name: 'InterviewTemplate', optional: true
      has_many :interview_questions, dependent: :destroy
      has_many :answers, through: :interview_questions

      validates :interviewee_name, presence: true
      validates :status, presence: true
      validates :unique_link_id, presence: true, uniqueness: true

      enum status: { pending: 'pending', in_progress: 'in_progress', completed: 'completed', expired: 'expired' }

      before_validation :generate_unique_link_id, on: :create

      private

      def generate_unique_link_id
        self.unique_link_id = SecureRandom.hex(10) unless unique_link_id.present?
      end
    end
    ```
*   **`app/models/interview_question.rb`:**
    ```ruby
    # app/models/interview_question.rb
    class InterviewQuestion < ApplicationRecord
      belongs_to :interview
      has_one :answer, dependent: :destroy # Each interview_question has one answer

      validates :question_text, presence: true
      validates :display_order, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :display_order, uniqueness: { scope: :interview_id }

      default_scope { order(:display_order) }
    end
    ```
*   **`app/models/answer.rb`:**
    ```ruby
    # app/models/answer.rb
    class Answer < ApplicationRecord
      belongs_to :interview_question
      has_one_attached :audio_file # For Active Storage attachment

      validates :stt_status, presence: true

      enum stt_status: { pending: 'pending', processing: 'processing', completed: 'completed', failed: 'failed' }
    end
    ```

### 2.3. 인증 (Devise) 설정

관리자 접근을 위한 인증 시스템을 구축합니다.

*   **Devise 설치:** `Gemfile`에 `gem 'devise'` 추가 후 `bundle install`, `rails generate devise:install`, `rails generate devise User` 실행.
*   **관리자 역할:** `User` 모델에 `is_admin:boolean` 컬럼을 추가하거나, `rolify`와 같은 gem을 사용하여 역할 기반 접근 제어를 구현합니다. 초기에는 `is_admin` 컬럼으로 간단하게 구현합니다.
    *   `rails generate migration AddIsAdminToUsers is_admin:boolean`
    *   마이그레이션 파일에서 `add_column :users, :is_admin, :boolean, default: false` 추가.
*   **관리자 라우트 보호:** `config/routes.rb`에서 관리자 관련 라우트를 `authenticate :user, lambda { |u| u.is_admin? } do ... end` 블록으로 감싸 보호합니다.

### 2.4. 관리자 패널 - 템플릿 관리

인터뷰 템플릿 및 질문을 생성, 조회, 수정, 삭제하는 기능을 구현합니다.

*   **라우트 (`config/routes.rb`):**
    ```ruby
    # config/routes.rb
    Rails.application.routes.draw do
      devise_for :users

      authenticate :user, lambda { |u| u.is_admin? } do
        namespace :admin do
          root 'dashboard#index' # Admin dashboard
          resources :interview_templates do
            resources :template_questions, only: [:new, :create, :edit, :update, :destroy] # Nested for template questions
          end
          resources :interviews, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
            member do
              post :transcribe_answer # Action to trigger STT for a specific answer
            end
          end
        end
      end

      # Public facing routes for interviewees
      namespace :public do
        resources :interviews, param: :unique_link_id, only: [:show] do
          resources :answers, only: [:create] # For submitting answers
        end
      end

      # Webhook for STT callbacks
      post '/api/stt-webhook', to: 'webhooks#stt_callback'

      root 'home#index' # Or redirect to admin dashboard if user is admin
    end
    ```
*   **컨트롤러:**
    *   `app/controllers/admin/interview_templates_controller.rb`
    *   `app/controllers/admin/template_questions_controller.rb` (nested under `interview_templates`)
    *   CRUD 액션 구현 및 `accepts_nested_attributes_for`를 활용하여 템플릿과 질문을 함께 처리하는 폼 구현.
*   **뷰 (ERB):**
    *   `app/views/admin/interview_templates/index.html.erb` (목록)
    *   `app/views/admin/interview_templates/new.html.erb` (생성 폼)
    *   `app/views/admin/interview_templates/edit.html.erb` (수정 폼)
    *   `app/views/admin/interview_templates/_form.html.erb` (부분 폼)
    *   Hotwire (Turbo Frames/Streams)를 사용하여 질문 추가/삭제 시 동적인 UI 업데이트 구현.

### 2.5. 관리자 패널 - 인터뷰 생성

관리자가 새 인터뷰 세션을 생성하고, 템플릿을 선택하거나 수동으로 질문을 추가하며, 고유 링크를 생성하는 기능을 구현합니다.

*   **컨트롤러 (`app/controllers/admin/interviews_controller.rb`):**
    *   `new`, `create` 액션 구현.
    *   `new` 액션에서 템플릿 선택 드롭다운 제공.
    *   `create` 액션에서 선택된 템플릿의 질문을 `InterviewQuestion`으로 복사하거나, 수동으로 입력된 질문을 처리.
    *   `Interview` 생성 시 `unique_link_id` 자동 생성.
    *   생성 후 인터뷰 상세 페이지로 리다이렉트하여 고유 링크 표시.
*   **뷰:**
    *   `app/views/admin/interviews/new.html.erb` (인터뷰 생성 폼)
    *   `app/views/admin/interviews/show.html.erb` (생성된 인터뷰의 고유 링크 표시)

### 2.6. 인터뷰 대상자 인터페이스

고유 링크를 통해 접근 가능한 공개 인터페이스를 개발하여 질문을 표시하고 브라우저 기반 오디오 녹음을 통해 답변을 제출할 수 있도록 합니다.

*   **컨트롤러 (`app/controllers/public/interviews_controller.rb`):**
    *   `show` 액션 구현: `unique_link_id`를 파라미터로 받아 해당 `Interview`와 `InterviewQuestion` 목록을 조회.
    *   인터뷰 상태(`status`)에 따라 다른 뷰를 렌더링 (예: `pending`, `in_progress`, `completed`).
*   **컨트롤러 (`app/controllers/public/answers_controller.rb`):**
    *   `create` 액션 구현: 오디오 파일(Active Storage)과 함께 답변을 제출받아 `Answer` 레코드 생성.
    *   오디오 녹음은 클라이언트 측 JavaScript (StimulusJS)를 사용하여 처리하고, 녹음된 Blob 데이터를 서버로 전송.
*   **뷰:**
    *   `app/views/public/interviews/show.html.erb`:
        *   질문 목록을 `display_order`에 따라 순서대로 표시.
        *   각 질문에 대한 오디오 녹음 UI (시작, 중지, 재생 버튼).
        *   StimulusJS를 사용하여 MediaRecorder API를 활용한 오디오 녹음 기능 구현.
        *   녹음 완료 시, `FormData`를 사용하여 오디오 파일을 포함한 답변 데이터를 `answers#create` 액션으로 비동기 전송.
        *   모든 질문에 답변 완료 시, 인터뷰 상태를 `completed`로 업데이트하는 버튼 제공.

### 2.7. STT 통합

개별 `Answer` 레코드에 대한 STT를 트리거하는 백그라운드 작업과 STT 서비스로부터 결과를 수신하는 웹훅 엔드포인트를 개발합니다.

*   **백그라운드 잡 (`app/jobs/transcribe_audio_job.rb`):**
    ```ruby
    # app/jobs/transcribe_audio_job.rb
    class TranscribeAudioJob < ApplicationJob
      queue_as :default # Or a specific queue for STT

      def perform(answer_id)
        answer = Answer.find_by(id: answer_id)
        return unless answer && answer.audio_file.attached? && answer.pending?

        answer.processing! # Update status to processing

        begin
          # Call external STT service (e.g., Naver CLOVA Speech API, OpenAI Whisper API)
          # This part requires implementing a client for the STT service
          # Example:
          # stt_service = SttService.new
          # audio_url = Rails.application.routes.url_helpers.rails_blob_url(answer.audio_file, only_path: true) # Or direct S3 URL
          # response = stt_service.transcribe(audio_url, callback_url: 'YOUR_WEBHOOK_URL', answer_id: answer.id)

          # For now, simulate success/failure
          if rand(10) > 1 # Simulate 90% success rate
            # In a real scenario, the STT service would call the webhook with the result
            # For testing, we might directly update here or have a mock webhook
            answer.update!(stt_status: :completed, transcript_result: { text: "Simulated transcript for answer #{answer.id}", words: [] })
          else
            answer.failed!
          end

        rescue StandardError => e
          answer.failed!
          Rails.logger.error "STT transcription failed for Answer #{answer_id}: #{e.message}"
        end
      end
    end
    ```
*   **STT 서비스 클라이언트 (`app/services/stt_service.rb`):**
    *   외부 STT API (예: Naver CLOVA Speech API, OpenAI Whisper API)와 통신하는 로직을 캡슐화하는 서비스 객체를 구현합니다. `HTTParty` 또는 `Faraday`와 같은 HTTP 클라이언트 라이브러리를 사용합니다.
*   **웹훅 컨트롤러 (`app/controllers/webhooks_controller.rb`):**
    *   STT 서비스로부터 콜백을 받아 `Answer` 레코드를 업데이트합니다.
    ```ruby
    # app/controllers/webhooks_controller.rb
    class WebhooksController < ApplicationController
      skip_before_action :verify_authenticity_token # Webhooks typically don't need CSRF protection

      def stt_callback
        # Parse the incoming payload from the STT service
        # Example payload structure (adjust based on actual STT service)
        payload = JSON.parse(request.body.read)
        answer_id = payload['answer_id']
        transcript_data = payload['transcript_data'] # This should be the full JSON from STT

        answer = Answer.find_by(id: answer_id)

        if answer
          answer.update!(stt_status: :completed, transcript_result: transcript_data)
          head :ok
        else
          Rails.logger.warn "STT Webhook: Answer with ID #{answer_id} not found."
          head :not_found
        end
      rescue JSON::ParserError => e
        Rails.logger.error "STT Webhook: Invalid JSON payload: #{e.message}"
        head :bad_request
      rescue StandardError => e
        Rails.logger.error "STT Webhook: Error processing callback: #{e.message}"
        head :internal_server_error
      end
    end
    ```
*   **STT 트리거:** 관리자 패널의 인터뷰 상세 페이지에서 특정 답변에 대한 STT를 수동으로 트리거하는 버튼을 추가하고, 해당 버튼 클릭 시 `TranscribeAudioJob.perform_later(answer.id)`를 호출하도록 합니다.

### 2.8. 관리자 패널 - 결과 검토

관리자가 인터뷰 세션을 보고, 각 답변의 오디오 재생 및 스크립트 표시를 제공하는 대시보드를 구현합니다.

*   **컨트롤러 (`app/controllers/admin/interviews_controller.rb`):**
    *   `index` 액션: 모든 인터뷰 목록 표시.
    *   `show` 액션: 특정 인터뷰의 상세 정보, `InterviewQuestion` 목록, 각 `Answer`의 상태, 오디오 파일, STT 스크립트 표시.
*   **뷰 (`app/views/admin/interviews/show.html.erb`):**
    *   인터뷰 질문과 답변을 순서대로 표시.
    *   각 답변에 대해:
        *   오디오 플레이어 (HTML5 `<audio>` 태그).
        *   STT 상태 표시 (뱃지).
        *   `transcript_result` (JSONB)에서 추출한 스크립트 텍스트 표시.
        *   (선택 사항) 스크립트 편집 기능.
        *   (고급) 오디오 재생과 스크립트 텍스트 동기화 (StimulusJS를 사용하여 `transcript_result`의 단어별 타임스탬프 활용).

### 2.9. 프론트엔드 스타일링 (Tailwind CSS & Hotwire)

Rails 프로젝트에 Tailwind CSS를 통합하고, 디자인 가이드라인을 모든 뷰에 적용하며, Hotwire를 사용하여 동적인 UI 요소를 구현합니다.

*   **Tailwind CSS 설치:**
    *   `gem 'tailwindcss-rails'` 추가 후 `bundle install`.
    *   `rails tailwindcss:install` 실행.
    *   `tailwind.config.js` 파일에 `devlog/20250718_002_design_guidelines_ror.md`에 명시된 색상 팔레트, 폰트 크기, 간격 등을 `theme.extend` 섹션에 추가.
*   **폰트 설정:**
    *   `app/assets/stylesheets/application.css`에 `@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700&display=swap');` 추가.
    *   `tailwind.config.js`에서 `font-family`를 `Noto Sans KR`로 설정.
*   **레이아웃 (`app/views/layouts/application.html.erb`):**
    *   디자인 가이드라인에 따라 2-컬럼 관리자 레이아웃 구현 (사이드바, 메인 콘텐츠 영역).
    *   `max-w-7xl` 등의 Tailwind 클래스를 사용하여 콘텐츠 너비 제한.
*   **컴포넌트 스타일링:**
    *   모든 버튼, 폼 필드, 테이블, 뱃지 등에 디자인 가이드라인에 명시된 Tailwind CSS 클래스를 적용.
*   **Hotwire (Turbo, Stimulus):**
    *   Rails 7 기본 설정에 포함되어 있으므로, 이를 활용하여 페이지 리로드 없이 동적인 상호작용을 구현합니다.
    *   예: 템플릿 질문 추가/삭제, 답변 제출, STT 상태 업데이트 등.
    *   StimulusJS 컨트롤러를 사용하여 오디오 녹음, 재생, 스크립트 동기화와 같은 복잡한 클라이언트 측 로직을 관리합니다.

### 2.10. 테스트

모델, 컨트롤러 및 백그라운드 작업에 대한 단위 및 통합 테스트를 작성합니다.

*   **테스트 프레임워크:** Rails 기본 MiniTest 또는 RSpec (선택 사항).
*   **모델 테스트:** 각 모델의 유효성 검사, 관계, 콜백 등을 테스트합니다.
*   **컨트롤러 테스트:** 각 컨트롤러 액션의 동작, 파라미터 처리, 뷰 렌더링, 리다이렉션 등을 테스트합니다.
*   **잡 테스트:** `TranscribeAudioJob`과 같은 백그라운드 잡이 올바르게 큐에 들어가고 실행되는지, 예외 처리가 잘 되는지 테스트합니다.
*   **서비스 객체 테스트:** `SttService`와 같은 외부 서비스 연동 로직을 단위 테스트합니다.
*   **통합 테스트 (System Tests):** Capybara를 사용하여 관리자 및 인터뷰 대상자 워크플로우를 엔드투엔드로 테스트합니다. (예: 관리자가 템플릿을 생성하고, 인터뷰를 만들고, 인터뷰 대상자가 답변을 제출하고, 관리자가 결과를 확인하는 전체 흐름).

## 3. 개발 순서 (권장)

1.  **데이터베이스 스키마 및 모델:** 가장 먼저 마이그레이션과 모델을 구현하여 시스템의 기반을 다집니다.
2.  **인증 (Devise):** 관리자 로그인 기능을 먼저 구현하여 개발 중 관리자 패널에 접근할 수 있도록 합니다.
3.  **관리자 패널 - 템플릿 관리:** 템플릿 및 질문 CRUD 기능을 구현하여 인터뷰 콘텐츠를 정의할 수 있도록 합니다.
4.  **관리자 패널 - 인터뷰 생성:** 템플릿을 기반으로 인터뷰 세션을 생성하는 기능을 구현합니다.
5.  **인터뷰 대상자 인터페이스 (녹음/업로드 제외):** 질문 표시 및 기본 UI를 먼저 구현합니다.
6.  **인터뷰 대상자 인터페이스 (녹음/업로드):** 브라우저 기반 오디오 녹음 및 Active Storage를 통한 파일 업로드 기능을 구현합니다.
7.  **STT 통합 (잡 및 웹훅):** 백그라운드 STT 처리 및 콜백 수신 로직을 구현합니다.
8.  **관리자 패널 - 결과 검토:** STT 결과 및 오디오 재생 기능을 포함한 결과 대시보드를 구현합니다.
9.  **프론트엔드 스타일링:** 모든 뷰에 디자인 가이드라인을 적용하고 Hotwire를 활용하여 동적인 상호작용을 개선합니다.
10. **테스트:** 각 기능 구현 후 관련 테스트를 작성하고, 전체 시스템 테스트를 통해 안정성을 확보합니다.

이 계획은 "Echoes of Korea" 프로젝트의 Q&A 기반 인터뷰 시스템을 성공적으로 구축하기 위한 로드맵이 될 것입니다.
