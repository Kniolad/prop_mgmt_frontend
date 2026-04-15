<template>
  <div>
    <h1>Property Manager</h1>
<input v-model="newName" placeholder="Property name" />
<button @click="addProperty">Add</button>
    <div v-if="properties.length === 0">
      No properties found
    </div>

    <div v-else>
      <div v-for="p in properties" :key="p.id">
        {{ p.name }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const properties = ref([])

onMounted(async () => {
  const res = await fetch('https://prop-mgmt-api-807815759229.us-central1.run.app/properties')
  const data = await res.json()
  properties.value = data
})

const newName = ref("")

async function loadProperties() {
  const res = await fetch('https://prop-mgmt-api-807815759229.us-central1.run.app/properties')
  properties.value = await res.json()
}

async function addProperty() {
  await fetch('https://prop-mgmt-api-807815759229.us-central1.run.app/properties', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      name: newName.value
    })
  })

  newName.value = ""
  loadProperties()
}
</script>

