# Plan: Q&A-Based Interview System Architecture

## 1. Executive Summary

This document outlines a new architecture for the "Echoes of Korea" project, shifting from a single, long-form interview model to a structured, **Question & Answer (Q&A) based interview system**. This design enhances flexibility, scalability, and user experience for both administrators and interviewees. It introduces a system of reusable **Interview Templates**, structured **Interview Sessions**, and **individual Answer tracking**, with each answer having its own audio and STT (Speech-to-Text) transcript.

## 2. Core Concept: From Monolith to Granular Sessions

The fundamental change is to treat an "interview" not as one monolithic audio file, but as a **Session** composed of multiple, distinct `(Question, Answer)` pairs. This granular approach allows for greater control, better data management, and more sophisticated features in the future.

## 3. Detailed Database Schema Design

A normalized, multi-table schema is proposed to support this new model. This structure ensures data integrity, performance, and scalability.

### a. `interview_templates`
- **Purpose:** Manages reusable sets of questions for different interview types.
- **Columns:**
    - `id` (UUID, PK): Primary Key.
    - `template_name` (TEXT, NOT NULL): Descriptive name (e.g., "Senior Backend Engineer Screening").
    - `description` (TEXT): A brief explanation of the template's purpose.
    - `created_by` (UUID, FK to `users.id`): The administrator who created the template.
    - `created_at` (TIMESTAMPTZ): Timestamp of creation.
    - `updated_at` (TIMESTAMPTZ): Timestamp of last update.

### b. `template_questions`
- **Purpose:** Stores the individual questions that belong to a specific template.
- **Columns:**
    - `id` (UUID, PK): Primary Key.
    - `template_id` (UUID, FK to `interview_templates.id`, NOT NULL): Links the question to a template.
    - `question_text` (TEXT, NOT NULL): The content of the question (e.g., "Describe a challenging project you've worked on.").
    - `display_order` (INTEGER, NOT NULL): Defines the sequence of questions within the template.
    - `estimated_time_seconds` (INTEGER): Optional: suggested answer duration.

### c. `interviews`
- **Purpose:** Represents a single, unique interview session conducted with an interviewee.
- **Columns:**
    - `id` (UUID, PK): Primary Key.
    - `interviewee_name` (TEXT, NOT NULL): Name of the person being interviewed.
    - `interviewee_email` (TEXT): Email of the interviewee.
    - `status` (TEXT, NOT NULL, DEFAULT 'pending'): The current state of the session ('pending', 'in_progress', 'completed', 'expired').
    - `created_from_template_id` (UUID, FK to `interview_templates.id`): The template used to generate this session. Can be NULL if questions were added manually.
    - `unique_link_id` (TEXT, UNIQUE, NOT NULL): A secure, unique identifier for the interviewee's access link.
    - `created_at` (TIMESTAMPTZ): Timestamp of creation.
    - `updated_at` (TIMESTAMPTZ): Timestamp of last update.

### d. `interview_questions`
- **Purpose:** Stores a snapshot of the questions for a specific interview session. This de-normalization is crucial to prevent a live interview from being affected by later changes to the source template.
- **Columns:**
    - `id` (UUID, PK): Primary Key.
    - `interview_id` (UUID, FK to `interviews.id`, NOT NULL): Links the question to a specific interview session.
    - `question_text` (TEXT, NOT NULL): The question content as it was at the time of interview creation.
    - `display_order` (INTEGER, NOT NULL): The sequence of questions for this specific interview.

### e. `answers`
- **Purpose:** The core table for storing interviewee responses. Each row corresponds to a single answer for a single question in an interview session.
- **Columns:**
    - `id` (UUID, PK): Primary Key.
    - `interview_question_id` (UUID, FK to `interview_questions.id`, NOT NULL): Links the answer to the specific question asked.
    - `audio_file_url` (TEXT): URL of the recorded audio file in Supabase Storage.
    - `stt_status` (TEXT, NOT NULL, DEFAULT 'pending'): Status of the STT process ('pending', 'processing', 'completed', 'failed').
    - `transcript_result` (JSONB): The full JSON response from the STT service, including word-level timestamps, confidence scores, etc.
    - `created_at` (TIMESTAMPTZ): Timestamp of creation.
    - `updated_at` (TIMESTAMPTZ): Timestamp of last update.

## 4. User & System Workflows

### a. Administrator Workflow
1.  **Template Management:**
    - Admins can create, view, update, and delete `interview_templates`.
    - Within a template, they can add, edit, reorder, and delete `template_questions`.
2.  **Interview Creation:**
    - An admin initiates a new interview.
    - They can choose to populate it from an existing `interview_template` or create a custom set of questions.
    - They input the interviewee's details.
    - The system generates a new `interviews` record and copies the relevant questions into `interview_questions`.
    - A unique access link (using `unique_link_id`) is generated and displayed to the admin to share with the interviewee.
3.  **Result Review:**
    - The admin dashboard lists all interview sessions and their `status`.
    - Clicking a session reveals all `interview_questions` and their corresponding `answers`.
    - For each answer, the admin can play the `audio_file_url` and view the formatted `transcript_result`. The UI should highlight the text in sync with audio playback, using the timestamps from the JSONB data.

### b. Interviewee Workflow
1.  **Access:** The interviewee opens the unique link provided by the admin.
2.  **Answering Questions:**
    - The UI presents the `interview_questions` one by one in the correct `display_order`.
    - For each question, the interviewee uses a browser-based recorder to record their audio answer.
    - Upon saving an answer, the audio is uploaded to Supabase Storage, and a new `answers` record is created with the `audio_file_url`.
3.  **Submission:** After answering all questions, the interviewee submits the entire session, which updates the `interviews` status to 'completed'.

### c. STT & Backend Workflow
1.  **Triggering:** The STT process is initiated for a single answer, not the whole interview. This can be triggered automatically upon audio upload or manually via an admin action.
2.  **Process:**
    - An API call is made to a new endpoint, e.g., `POST /api/answers/[answer_id]/transcribe`.
    - The backend updates the `answers.stt_status` to 'processing'.
    - It sends the `audio_file_url` to the chosen STT service (e.g., Naver Clova, Google STT). The request to the STT service must include the `answer_id` so the result can be mapped back correctly.
    - The STT service, upon completion, calls a webhook endpoint in our application, e.g., `POST /api/stt-webhook`.
3.  **Webhook Handling:**
    - The webhook handler receives the STT result and the `answer_id`.
    - It finds the corresponding record in the `answers` table.
    - It updates the `stt_status` to 'completed' and saves the entire STT JSON payload into the `transcript_result` column.

## 5. API Endpoint Plan

A RESTful API structure will support these workflows.

- **Admin-facing:**
    - `GET /api/admin/templates`
    - `POST /api/admin/templates`
    - `PUT /api/admin/templates/[id]`
    - `GET /api/admin/interviews`
    - `POST /api/admin/interviews`
    - `GET /api/admin/interviews/[id]` (Should return the interview with its questions and answers)
- **Interviewee-facing:**
    - `GET /api/interviews/[unique_link_id]` (Gets session details for the interviewee)
    - `POST /api/answers` (Submits a new audio answer)
- **STT-related:**
    - `POST /api/answers/[id]/transcribe` (Initiates transcription for a specific answer)
    - `POST /api/stt-webhook` (Receives results from the external STT service)

## 6. Benefits of This Architecture

- **Scalability:** The system can handle a large number of interviews and answers efficiently.
- **Flexibility:** New features, such as answer analysis, scoring, or re-answering specific questions, can be added easily by extending the `answers` table.
- **Data Integrity:** Decoupling `interview_questions` from `template_questions` ensures that historical interview data remains accurate and unchanged.
- **Performance:** Queries can be optimized to fetch only the necessary data (e.g., loading interview lists without the heavy transcript data).
- **Improved User Experience:** Both admins and interviewees have a more structured and manageable interaction with the system.
