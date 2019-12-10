<template>
  <div class="container">
    <vue-canvas-nest :config="{ color: '64,158,255', count: 188 }" />
    <div>
      <h1 class="title">
        Ten-AI
      </h1>
      <div class="links">
        <a
          href="https://github.com/Ten-AI"
          target="_blank"
          class="button--blue"
        >
          GitHub
        </a>
      </div>
    </div>
  </div>
</template>

<script>
import vueCanvasNest from 'vue-canvas-nest'
export default {
  head() {
    return {
      title: 'Ten-AI'
    }
  },
  components: {
    vueCanvasNest
  }
}
</script>

<style>
.container {
  margin: 0 auto;
  min-height: 85vh;
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
}

.title {
  font-family: 'Quicksand', 'Source Sans Pro', -apple-system, BlinkMacSystemFont,
    'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  display: block;
  font-weight: 300;
  font-size: 100px;
  color: #409eff;
  letter-spacing: 1px;
}

.links {
  padding-top: 15px;
}
</style>
