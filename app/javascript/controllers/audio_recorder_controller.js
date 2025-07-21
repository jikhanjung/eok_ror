import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status", "audioPlayer", "submitButton", "recordingIndicator", "questionCard"]
  static values = { 
    questionId: Number,
    interviewId: String,
    locale: String
  }

  connect() {
    this.mediaRecorder = null
    this.audioChunks = []
    this.isRecording = false
    this.stream = null
    
    // Set up messages based on locale
    this.messages = this.localeValue === 'en' ? {
      start: "🎤 Start Recording",
      stop: "⏹ Stop Recording",
      recording: "Recording...",
      clickToStart: "Click to start recording",
      recordingInProgress: "Recording... Click to stop",
      recordingCompleted: "Recording Completed",
      submit: "Submit Answer",
      reRecord: "Re-record",
      submitting: "Submitting...",
      error: "Cannot access microphone. Please allow microphone permission in your browser settings.",
      submitError: "Failed to submit answer"
    } : {
      start: "🎤 녹음 시작",
      stop: "⏹ 녹음 중지",
      recording: "녹음 중...",
      clickToStart: "클릭하여 녹음 시작",
      recordingInProgress: "녹음 중... 클릭하여 중지",
      recordingCompleted: "녹음 완료",
      submit: "답변 제출",
      reRecord: "다시 녹음",
      submitting: "제출 중...",
      error: "마이크에 접근할 수 없습니다. 브라우저 설정에서 마이크 권한을 허용해주세요.",
      submitError: "답변 제출에 실패했습니다"
    }
  }

  async toggleRecording() {
    if (this.isRecording) {
      this.stopRecording()
    } else {
      await this.startRecording()
    }
  }

  async startRecording() {
    try {
      // Request microphone access
      this.stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      
      // Create MediaRecorder instance
      this.mediaRecorder = new MediaRecorder(this.stream)
      this.audioChunks = []
      
      // Set up event handlers
      this.mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          this.audioChunks.push(event.data)
        }
      }
      
      this.mediaRecorder.onstop = () => {
        this.handleRecordingComplete()
      }
      
      // Start recording
      this.mediaRecorder.start()
      this.isRecording = true
      
      // Update UI
      this.updateRecordingUI()
      
    } catch (error) {
      console.error("Error accessing microphone:", error)
      alert(this.messages.error)
    }
  }

  stopRecording() {
    if (this.mediaRecorder && this.isRecording) {
      this.mediaRecorder.stop()
      this.isRecording = false
      
      // Stop all tracks to release microphone
      if (this.stream) {
        this.stream.getTracks().forEach(track => track.stop())
      }
      
      this.updateRecordingUI()
    }
  }

  handleRecordingComplete() {
    // Create blob from audio chunks
    const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' })
    
    // Create URL for audio playback
    const audioUrl = URL.createObjectURL(audioBlob)
    
    // Show audio player
    if (this.hasAudioPlayerTarget) {
      this.audioPlayerTarget.src = audioUrl
      this.audioPlayerTarget.classList.remove("hidden")
    }
    
    // Store blob for submission
    this.recordedBlob = audioBlob
    
    // Show submit button
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.classList.remove("hidden")
    }
    
    // Update status
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = this.messages.recordingCompleted
      this.statusTarget.classList.remove("text-red-600")
      this.statusTarget.classList.add("text-green-600")
    }
    
    // Update button text
    this.buttonTarget.textContent = this.messages.reRecord
  }

  updateRecordingUI() {
    if (this.isRecording) {
      // Recording state
      this.buttonTarget.textContent = this.messages.stop
      this.buttonTarget.classList.remove("from-blue-600", "to-indigo-600", "hover:from-blue-700", "hover:to-indigo-700")
      this.buttonTarget.classList.add("from-red-600", "to-pink-600", "hover:from-red-700", "hover:to-pink-700")
      
      if (this.hasStatusTarget) {
        this.statusTarget.textContent = this.messages.recordingInProgress
        this.statusTarget.classList.remove("text-slate-500", "text-green-600")
        this.statusTarget.classList.add("text-red-600")
      }
      
      if (this.hasRecordingIndicatorTarget) {
        this.recordingIndicatorTarget.classList.remove("hidden")
      }
      
      // Hide audio player and submit button when re-recording
      if (this.hasAudioPlayerTarget) {
        this.audioPlayerTarget.classList.add("hidden")
      }
      if (this.hasSubmitButtonTarget) {
        this.submitButtonTarget.classList.add("hidden")
      }
    } else {
      // Not recording state
      this.buttonTarget.textContent = this.messages.start
      this.buttonTarget.classList.remove("from-red-600", "to-pink-600", "hover:from-red-700", "hover:to-pink-700")
      this.buttonTarget.classList.add("from-blue-600", "to-indigo-600", "hover:from-blue-700", "hover:to-indigo-700")
      
      if (this.hasStatusTarget) {
        this.statusTarget.textContent = this.messages.clickToStart
        this.statusTarget.classList.remove("text-red-600")
        this.statusTarget.classList.add("text-slate-500")
      }
      
      if (this.hasRecordingIndicatorTarget) {
        this.recordingIndicatorTarget.classList.add("hidden")
      }
    }
  }

  async submitAnswer() {
    if (!this.recordedBlob) return
    
    // Disable submit button
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.textContent = this.messages.submitting
    }
    
    // Create FormData
    const formData = new FormData()
    formData.append('answer[audio]', this.recordedBlob, `recording_${Date.now()}.webm`)
    formData.append('answer[interview_question_id]', this.questionIdValue)
    
    try {
      const response = await fetch(`/${this.localeValue}/public/interviews/${this.interviewIdValue}/answers`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: formData
      })
      
      if (response.ok) {
        // Mark question as completed
        if (this.hasQuestionCardTarget) {
          this.questionCardTarget.classList.add("opacity-60")
          
          // Update status indicator
          const statusIndicator = this.questionCardTarget.querySelector('[data-status-indicator]')
          if (statusIndicator) {
            statusIndicator.classList.remove("bg-yellow-100", "text-yellow-600")
            statusIndicator.classList.add("bg-green-100", "text-green-600")
            statusIndicator.textContent = this.localeValue === 'en' ? "Completed" : "답변 완료"
          }
        }
        
        // Hide recording interface
        this.element.classList.add("hidden")
        
        // Show next question if available
        const nextQuestion = document.querySelector(`[data-question-id="${this.questionIdValue + 1}"]`)
        if (nextQuestion) {
          const nextRecorder = nextQuestion.querySelector('[data-controller="audio-recorder"]')
          if (nextRecorder) {
            nextRecorder.classList.remove("hidden")
          }
        }
        
        // Update progress bar
        this.updateProgress()
        
      } else {
        throw new Error('Submit failed')
      }
    } catch (error) {
      console.error("Error submitting answer:", error)
      alert(this.messages.submitError)
      
      // Re-enable submit button
      if (this.hasSubmitButtonTarget) {
        this.submitButtonTarget.disabled = false
        this.submitButtonTarget.textContent = this.messages.submit
      }
    }
  }

  updateProgress() {
    const totalQuestions = document.querySelectorAll('[data-question-id]').length
    const completedQuestions = document.querySelectorAll('[data-status-indicator].bg-green-100').length
    const percentage = Math.round((completedQuestions / totalQuestions) * 100)
    
    const progressBar = document.querySelector('[data-progress-bar]')
    const progressText = document.querySelector('[data-progress-text]')
    
    if (progressBar) {
      progressBar.style.width = `${percentage}%`
    }
    if (progressText) {
      progressText.textContent = `${percentage}%`
    }
    
    // Enable complete button if all questions answered
    if (completedQuestions === totalQuestions) {
      const completeButton = document.querySelector('[data-complete-button]')
      if (completeButton) {
        completeButton.disabled = false
        completeButton.classList.remove("opacity-50", "cursor-not-allowed")
      }
    }
  }

  disconnect() {
    // Clean up when controller disconnects
    if (this.isRecording) {
      this.stopRecording()
    }
  }
}