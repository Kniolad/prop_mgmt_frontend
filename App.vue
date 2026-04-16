<template>
  <div>
    <h1>Property Manager</h1>
    <div class="form-group">
      <input v-model="newProperty.address" placeholder="Address" />
      <input v-model="newProperty.city" placeholder="City" />
      <input v-model="newProperty.state" placeholder="State" />
      <input v-model="newProperty.monthly_rent" type="number" placeholder="Monthly Rent" />
      <input v-model="newProperty.tenant_name" placeholder="Tenant Name" />
      <button @click="addProperty">Add Property</button>
    </div>
    
    <div v-if="properties.length === 0">
      No properties found
    </div>

    <div v-else>
      <div v-for="p in properties" :key="p.property_id" class="property-card">
        <h3>{{ p.address }}</h3>
        <p><strong>City:</strong> {{ p.city }}, {{ p.state }} {{ p.postal_code }}</p>
        <p><strong>Type:</strong> {{ p.property_type }}</p>
        <p><strong>Tenant:</strong> {{ p.tenant_name }}</p>
        <p><strong>Monthly Rent:</strong> ${{ p.monthly_rent }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const properties = ref([])

const newProperty = ref({
  address: '',
  city: '',
  state: '',
  monthly_rent: '',
  tenant_name: ''
})

const API_BASE_URL = 'https://prop-mgmt-api-807815759229.us-central1.run.app'

async function loadProperties() {
  try {
    const res = await fetch(`${API_BASE_URL}/properties`)
    properties.value = await res.json()
  } catch (error) {
    console.error('Failed to load properties:', error)
  }
}

onMounted(loadProperties)

async function addProperty() {
  try {
    await fetch(`${API_BASE_URL}/properties`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        address: newProperty.value.address,
        city: newProperty.value.city,
        state: newProperty.value.state,
        monthly_rent: parseFloat(newProperty.value.monthly_rent),
        tenant_name: newProperty.value.tenant_name
      })
    })

    newProperty.value = {
      address: '',
      city: '',
      state: '',
      monthly_rent: '',
      tenant_name: ''
    }
    
    await loadProperties()
  } catch (error) {
    console.error('Failed to add property:', error)
  }
}
</script>

<style scoped>
.form-group {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 20px;
  max-width: 500px;
}

.form-group input {
  padding: 8px;
  border: 1px solid #ccc;
  border-radius: 4px;
}

.form-group button {
  padding: 10px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.form-group button:hover {
  background-color: #0056b3;
}

.property-card {
  border: 1px solid #ddd;
  padding: 15px;
  margin-bottom: 10px;
  border-radius: 4px;
  background-color: #f9f9f9;
}

.property-card h3 {
  margin-top: 0;
}

.property-card p {
  margin: 5px 0;
}
</style>