import Cropper from 'cropperjs'
import 'cropperjs/dist/cropper.css'

class AvatarCropper {
  constructor() {
    this.fileInput = document.querySelector('#user_avatar')
    this.cropModal = document.querySelector('#crop-modal')
    this.cropImage = document.querySelector('#crop-image')
    this.previewImage = document.querySelector('#preview-image')
    this.cropButton = document.querySelector('#crop-button')
    this.cancelButton = document.querySelector('#cancel-crop')
    this.avatarPreview = document.querySelector('#avatar-preview')
    this.cropperInstance = null
    this.originalFile = null
    this.maxSizeInMB = 5

    if (this.fileInput) {
      this.init()
    }
  }

  init() {
    this.fileInput.addEventListener('change', (e) => this.handleFileSelect(e))
    this.cropButton.addEventListener('click', () => this.handleCrop())
    this.cancelButton.addEventListener('click', () => this.handleCancel())
  }

  handleFileSelect(e) {
    const file = e.target.files[0]
    if (!file) return

    const fileSizeInMB = file.size / (1024 * 1024)
    if (fileSizeInMB > this.maxSizeInMB) {
      alert(`File size must be less than ${this.maxSizeInMB}MB. Selected file is ${fileSizeInMB.toFixed(2)}MB.`)
      this.fileInput.value = ''
      return
    }

    this.originalFile = file
    const reader = new FileReader()
    reader.onload = (e) => {
      this.cropImage.src = e.target.result
      this.previewImage.src = e.target.result
      this.showModal()
      this.initCropper()
    }
    reader.readAsDataURL(file)
    this.fileInput.value = ''
  }

  showModal() {
    this.cropModal.classList.remove('hidden')
  }

  hideModal() {
    this.cropModal.classList.add('hidden')
    if (this.cropperInstance) {
      this.cropperInstance.destroy()
      this.cropperInstance = null
    }
  }

  initCropper() {
    if (this.cropperInstance) {
      this.cropperInstance.destroy()
    }

    this.cropperInstance = new Cropper(this.cropImage, {
      aspectRatio: 1,
      viewMode: 1,
      dragMode: 'move',
      autoCropArea: 1,
      restore: false,
      guides: true,
      center: true,
      highlight: false,
      cropBoxMovable: true,
      cropBoxResizable: true,
      toggleDragModeOnDblclick: false,
      preview: '.preview-container',
      ready() {
        // Hide the grid lines on initial load
        const gridLines = document.querySelectorAll('.cropper-grid')
        gridLines.forEach(line => line.style.opacity = '0')
      }
    })
  }

  handleCrop() {
    if (!this.cropperInstance) return

    const canvas = this.cropperInstance.getCroppedCanvas({
      width: 400,
      height: 400
    })

    canvas.toBlob((blob) => {
      const croppedFile = new File([blob], this.originalFile.name, {
        type: this.originalFile.type
      })

      const dataTransfer = new DataTransfer()
      dataTransfer.items.add(croppedFile)
      this.fileInput.files = dataTransfer.files
      this.avatarPreview.src = canvas.toDataURL()
      this.hideModal()
    }, this.originalFile.type)
  }

  handleCancel() {
    this.hideModal()
  }
}

export default AvatarCropper 