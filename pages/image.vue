<template>
  <div style="text-align: center; margin-top: 50px;">
    <vue-canvas-nest :config="{ color: '64,158,255', count: 188 }" />

    <h1 style="margin-bottom: 20px;">AI 图像识别</h1>

    <div>
      <p>
        <video
          id="videoCamera"
          :width="videoWidth"
          :height="videoHeight"
          autoplay
          style="border-radius: 10px;"
        />
      </p>
      <el-button @click="setImage" type="primary" size="small">拍摄</el-button>
      <el-upload
        :action="apiUrl"
        :show-file-list="false"
        :on-success="handleUploadSuccess"
        :before-upload="handleBeforeUpload"
        class="upload-demo"
        name="img"
        style="margin-top: 10px;"
      >
        <el-button type="success" size="small">上传</el-button>
      </el-upload>
    </div>

    <p style="margin-top: 30px;">
      Power by
      <el-link type="primary" href="https://github.com/Ten-AI" target="_blank"
        >Ten-AI</el-link
      >
    </p>

    <el-dialog
      v-loading="dialogLoading"
      :visible.sync="showDialog"
      @close="imgSrc = ''"
      :close-on-click-modal="false"
      element-loading-text="没有GPU的孩子正在拼命奔跑..."
      element-loading-spinner="el-icon-loading"
      element-loading-background="rgba(0, 0, 0, 0.8)"
      title="识别结果"
      width="20%"
      center
    >
      <div style="text-align: center;">
        <el-avatar :size="100" :src="imgSrc" shape="square" fit="fill" />
      </div>
      <p
        slot="footer"
        :style="{ color: resColor }"
        style="text-align: center; font-weight: bold;"
        class="dialog-footer"
      >
        {{ res }}
      </p>
    </el-dialog>

    <canvas
      id="canvasCamera"
      :width="videoWidth"
      :height="videoHeight"
      style="display:none;"
    />
  </div>
</template>

<script>
import vueCanvasNest from 'vue-canvas-nest'
export default {
  components: {
    vueCanvasNest
  },
  head() {
    return {
      title: 'AI 图像识别'
    }
  },
  data() {
    return {
      // https://gcb.ncucoder.com/image/
      apiUrl: 'http://localhost:8000/image/',
      dialogLoading: true,
      showDialog: false,
      videoWidth: 450,
      videoHeight: 320,
      imgSrc: '',
      thisCanvas: null,
      thisContext: null,
      thisVideo: null,
      res: '',
      resColor: '#67C23A',
      loading: null
    }
  },
  mounted() {
    this.getCompetence()
  },
  beforeDestroy() {
    this.stopNavigator()
  },
  methods: {
    /* 调用权限 */
    getCompetence() {
      const _this = this
      this.thisCanvas = document.getElementById('canvasCamera')
      this.thisContext = this.thisCanvas.getContext('2d')
      this.thisVideo = document.getElementById('videoCamera')
      // 旧版本浏览器可能根本不支持mediaDevices，我们首先设置一个空对象
      if (navigator.mediaDevices === undefined) {
        navigator.mediaDevices = {}
      }
      // 一些浏览器实现了部分mediaDevices，我们不能只分配一个对象
      // 使用getUserMedia，因为它会覆盖现有的属性。
      // 这里，如果缺少getUserMedia属性，就添加它。
      if (navigator.mediaDevices.getUserMedia === undefined) {
        navigator.mediaDevices.getUserMedia = function(constraints) {
          // 首先获取现存的getUserMedia(如果存在)
          const getUserMedia =
            navigator.webkitGetUserMedia ||
            navigator.mozGetUserMedia ||
            navigator.getUserMedia
          // 有些浏览器不支持，会返回错误信息
          // 保持接口一致
          if (!getUserMedia) {
            return Promise.reject(
              new Error('getUserMedia is not implemented in this browser')
            )
          }
          // 否则，使用Promise将调用包装到旧的navigator.getUserMedia
          return new Promise(function(resolve, reject) {
            getUserMedia.call(navigator, constraints, resolve, reject)
          })
        }
      }
      const constraints = {
        audio: false,
        video: {
          width: this.videoWidth,
          height: this.videoHeight,
          transform: 'scaleX(-1)'
        }
      }
      navigator.mediaDevices
        .getUserMedia(constraints)
        .then(function(stream) {
          // 旧的浏览器可能没有srcObject
          if ('srcObject' in _this.thisVideo) {
            _this.thisVideo.srcObject = stream
          } else {
            // 避免在新的浏览器中使用它，因为它正在被弃用。
            _this.thisVideo.src = window.URL.createObjectURL(stream)
          }
          _this.thisVideo.onloadedmetadata = function(e) {
            _this.thisVideo.play()
          }
        })
        .catch((err) => {
          console.log(err)
        })
    },
    /* 绘制图片 */
    setImage() {
      const _this = this
      // canvas画图
      _this.thisContext.drawImage(
        _this.thisVideo,
        0,
        0,
        _this.videoWidth,
        _this.videoHeight
      )
      // 获取图片base64链接
      _this.imgSrc = this.thisCanvas.toDataURL('image/png')
      const loading = this.$loading({
        lock: true,
        text: '没有GPU的孩子正在努力奔跑...',
        spinner: 'el-icon-loading',
        background: 'rgba(0, 0, 0, 0.7)'
      })
      this.imageRecognize(loading)
    },
    /* 传给后端做图像识别 */
    imageRecognize(loading) {
      const arr = this.imgSrc.split(',')
      const mime = arr[0].match(/:(.*?);/)[1]
      const bstr = atob(arr[1])
      let n = bstr.length
      const u8arr = new Uint8Array(n)
      while (n--) {
        u8arr[n] = bstr.charCodeAt(n)
      }
      const image = new File([u8arr], 'hello-ai.png', { type: mime })

      const fd = new FormData()
      fd.append('img', image)
      const headers = {
        'Content-Type': 'multipart/form-data'
      }
      this.$axios
        .post(this.apiUrl, fd, {
          headers
        })
        .then((res) => {
          this.resColor = '#67C23A'
          this.res = res.data.msg
        })
        .catch((err) => {
          console.log(err)
          this.resColor = '#F56C6C'
          this.res = '请求服务失败'
        })
        .finally(() => {
          loading.close()
          this.showDialog = true
        })
    },
    /* 关闭摄像头 */
    stopNavigator() {
      this.thisVideo.srcObject.getTracks()[0].stop()
    },
    handleUploadSuccess(response, file, fileList) {
      console.log(file)
      console.log(response)
      // this.imgSrc = this.getObjectURL(file)
      this.showDialog = true
      this.loading.close()
      this.resColor = '#67C23A'
      this.res = response.data.msg
    },
    getObjectURL(file) {
      let url = null
      if (window.createObjectURL) {
        // basic
        url = window.createObjectURL(file)
      } else if (window.URL !== undefined) {
        // mozilla(firefox)
        url = window.URL.createObjectURL(file)
      } else if (window.webkitURL !== undefined) {
        // webkit or chrome
        url = window.webkitURL.createObjectURL(file)
      }
      return url
    },
    handleBeforeUpload(file) {
      this.loading = this.$loading({
        lock: true,
        text: '没有GPU的孩子正在努力奔跑...',
        spinner: 'el-icon-loading',
        background: 'rgba(0, 0, 0, 0.7)'
      })
    }
  }
}
</script>
