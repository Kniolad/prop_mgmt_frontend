<template>
  <div class="portal-shell">
    <div class="ambient ambient-1"></div>
    <div class="ambient ambient-2"></div>

    <div class="app-container">
      <header class="page-header">
        <div>
          <p class="eyebrow">Portfolio workspace</p>
          <h1>Property Management Portal</h1>
          <p class="page-subtitle">
            A luxury dark mode dashboard for properties, cash flow, and portfolio visibility.
          </p>
        </div>
        <div class="header-chip">{{ properties.length }} {{ properties.length === 1 ? 'Property' : 'Properties' }}</div>
      </header>

      <div class="nav-tabs">
        <button @click="activeTab = 'properties'" :class="{ active: activeTab === 'properties' }">Properties</button>
        <button @click="activeTab = 'income'" :class="{ active: activeTab === 'income' }">Income</button>
        <button @click="activeTab = 'expenses'" :class="{ active: activeTab === 'expenses' }">Expenses</button>
        <button @click="activeTab = 'analytics'" :class="{ active: activeTab === 'analytics' }">Analytics</button>
      </div>

      <div v-if="activeTab === 'properties'" class="tab-content">
        <section class="section-header">
          <div>
            <p class="section-kicker">Manage portfolio</p>
            <h2>Properties</h2>
          </div>
        </section>

        <div class="form-card glass-card">
          <div class="card-title-row">
            <div>
              <p class="section-kicker">Directory</p>
              <h3>{{ editingProperty ? 'Edit Property' : 'Add New Property' }}</h3>
            </div>
          </div>

          <div class="form-grid">
            <input v-model="newProperty.address" placeholder="Address" />
            <input v-model="newProperty.city" placeholder="City" />
            <input v-model="newProperty.state" placeholder="State" />
            <input v-model="newProperty.postal_code" placeholder="Postal Code" />
            <input v-model="newProperty.property_type" placeholder="Property Type (e.g., Apartment, House)" />
            <input v-model.number="newProperty.monthly_rent" type="number" placeholder="Monthly Rent" />
            <input v-model="newProperty.tenant_name" placeholder="Tenant Name" class="span-2" />
          </div>

          <div class="button-group">
            <button @click="saveProperty" class="btn-primary">
              {{ editingProperty ? 'Update' : 'Add' }} Property
            </button>
            <button v-if="editingProperty" @click="cancelEdit" class="btn-secondary">Cancel</button>
          </div>
        </div>

        <div v-if="properties.length === 0" class="empty-state glass-card">
          <div class="empty-icon">⌂</div>
          <p>No properties found. Add your first property above.</p>
        </div>

        <div v-else class="properties-grid">
          <article v-for="p in properties" :key="p.property_id" class="property-card glass-card">
            <div class="property-media" :style="{ backgroundImage: `url(${generatePropertyImage(p)})` }">
              <div class="media-overlay"></div>
              <div class="media-top-row">
                <span class="property-badge">{{ p.property_type || 'Property' }}</span>
                <span class="property-id">ID {{ p.property_id }}</span>
              </div>
              <div class="media-bottom-row">
                <h3>{{ p.address }}</h3>
                <p>{{ p.city }}, {{ p.state }} {{ p.postal_code || '' }}</p>
              </div>
            </div>

            <div class="card-details">
              <div class="metric-row">
                <span>Tenant</span>
                <strong>{{ p.tenant_name || 'Vacant' }}</strong>
              </div>
              <div class="metric-row">
                <span>Monthly rent</span>
                <strong class="money">${{ Number(p.monthly_rent || 0).toLocaleString() }}</strong>
              </div>
              <div class="metric-row">
                <span>Status</span>
                <strong>{{ p.tenant_name ? 'Occupied' : 'Available' }}</strong>
              </div>
            </div>

            <div class="card-actions">
              <button @click="editPropertyRecord(p)" class="btn-small">Edit</button>
              <button @click="viewPropertyDetails(p.property_id)" class="btn-small btn-accent">View Details</button>
              <button @click="deletePropertyRecord(p.property_id)" class="btn-small btn-danger">Delete</button>
            </div>
          </article>
        </div>
      </div>

      <div v-if="activeTab === 'income'" class="tab-content">
        <section class="section-header">
          <div>
            <p class="section-kicker">Cash inflow</p>
            <h2>Income Records</h2>
          </div>
        </section>

        <div class="form-card glass-card">
          <h3>Select Property</h3>
          <div class="form-group">
            <select v-model.number="selectedPropertyForIncome" class="select-large">
              <option value="">-- Select a Property --</option>
              <option v-for="p in properties" :key="p.property_id" :value="p.property_id">
                {{ p.address }} (ID: {{ p.property_id }})
              </option>
            </select>
          </div>
        </div>

        <div v-if="selectedPropertyForIncome" class="form-card glass-card">
          <h3>Add Income Record</h3>
          <div class="form-grid compact-grid">
            <input v-model.number="newIncome.amount" type="number" placeholder="Amount" step="0.01" />
            <input v-model="newIncome.date" type="date" />
            <input v-model="newIncome.description" placeholder="Description (e.g., Monthly Rent)" class="span-2" />
          </div>
          <button @click="addIncome" class="btn-primary inline-button">Record Income</button>
        </div>

        <div v-if="!selectedPropertyForIncome" class="empty-state glass-card">
          <div class="empty-icon">⌁</div>
          <p>Select a property to view and add income records.</p>
        </div>

        <div v-else-if="incomeRecords.length === 0" class="empty-state glass-card">
          <div class="empty-icon">⌁</div>
          <p>No income records for this property.</p>
        </div>

        <div v-else class="records-grid">
          <div v-for="inc in incomeRecords" :key="inc.income_id" class="record-card income glass-card">
            <div class="record-header">
              <span class="record-id">#{{ inc.income_id }}</span>
              <span class="record-date">{{ formatDate(inc.date) }}</span>
            </div>
            <p class="record-amount">${{ inc.amount }}</p>
            <p class="record-description">{{ inc.income_description || 'No description' }}</p>
          </div>
        </div>

        <div v-if="selectedPropertyForIncome && incomeRecords.length > 0" class="summary-card glass-card">
          <h4>Income Summary</h4>
          <p><strong>Total Income:</strong> <span class="highlight success">${{ calculateTotalIncome() }}</span></p>
          <p><strong>Records Count:</strong> {{ incomeRecords.length }}</p>
        </div>
      </div>

      <div v-if="activeTab === 'expenses'" class="tab-content">
        <section class="section-header">
          <div>
            <p class="section-kicker">Cash outflow</p>
            <h2>Expense Records</h2>
          </div>
        </section>

        <div class="form-card glass-card">
          <h3>Select Property</h3>
          <div class="form-group">
            <select v-model.number="selectedPropertyForExpense" class="select-large">
              <option value="">-- Select a Property --</option>
              <option v-for="p in properties" :key="p.property_id" :value="p.property_id">
                {{ p.address }} (ID: {{ p.property_id }})
              </option>
            </select>
          </div>
        </div>

        <div v-if="selectedPropertyForExpense" class="form-card glass-card">
          <h3>Add Expense Record</h3>
          <div class="form-grid compact-grid">
            <input v-model.number="newExpense.amount" type="number" placeholder="Amount" step="0.01" />
            <input v-model="newExpense.date" type="date" />
            <input v-model="newExpense.description" placeholder="Description (e.g., Maintenance, Repairs)" class="span-2" />
          </div>
          <button @click="addExpense" class="btn-primary inline-button">Record Expense</button>
        </div>

        <div v-if="!selectedPropertyForExpense" class="empty-state glass-card">
          <div class="empty-icon">⌁</div>
          <p>Select a property to view and add expense records.</p>
        </div>

        <div v-else-if="expenseRecords.length === 0" class="empty-state glass-card">
          <div class="empty-icon">⌁</div>
          <p>No expense records for this property.</p>
        </div>

        <div v-else class="records-grid">
          <div v-for="exp in expenseRecords" :key="exp.expense_id" class="record-card expense glass-card">
            <div class="record-header">
              <span class="record-id">#{{ exp.expense_id }}</span>
              <span class="record-date">{{ formatDate(exp.date) }}</span>
            </div>
            <p class="record-amount">${{ exp.amount }}</p>
            <p class="record-description">{{ exp.expense_description || 'No description' }}</p>
          </div>
        </div>

        <div v-if="selectedPropertyForExpense && expenseRecords.length > 0" class="summary-card glass-card">
          <h4>Expense Summary</h4>
          <p><strong>Total Expenses:</strong> <span class="highlight danger">${{ calculateTotalExpenses() }}</span></p>
          <p><strong>Records Count:</strong> {{ expenseRecords.length }}</p>
        </div>
      </div>

      <div v-if="activeTab === 'analytics'" class="tab-content">
        <section class="section-header">
          <div>
            <p class="section-kicker">Portfolio performance</p>
            <h2>Financial Analytics</h2>
          </div>
        </section>

        <div class="form-card glass-card">
          <h3>Select Property</h3>
          <div class="form-group">
            <select v-model.number="selectedPropertyForAnalytics" class="select-large">
              <option value="">-- Select a Property --</option>
              <option v-for="p in properties" :key="p.property_id" :value="p.property_id">
                {{ p.address }} (ID: {{ p.property_id }})
              </option>
            </select>
          </div>
        </div>

        <div v-if="selectedPropertyForAnalytics" class="analytics-dashboard">
          <div class="analytics-card glass-card">
            <h4>Total Income</h4>
            <p class="analytics-value success">${{ calculateTotalIncomeForProperty() }}</p>
            <p class="analytics-subtitle">All-time income</p>
          </div>

          <div class="analytics-card glass-card">
            <h4>Total Expenses</h4>
            <p class="analytics-value danger">${{ calculateTotalExpensesForProperty() }}</p>
            <p class="analytics-subtitle">All-time expenses</p>
          </div>

          <div class="analytics-card glass-card">
            <h4>Net Income</h4>
            <p class="analytics-value" :class="{ success: netIncome >= 0, danger: netIncome < 0 }">
              ${{ netIncome }}
            </p>
            <p class="analytics-subtitle">Income minus expenses</p>
          </div>

          <div class="analytics-card glass-card">
            <h4>Monthly Rent</h4>
            <p class="analytics-value">${{ getPropertyMonthlyRent(selectedPropertyForAnalytics) }}</p>
            <p class="analytics-subtitle">Recurring revenue</p>
          </div>
        </div>

        <div v-else class="empty-state glass-card">
          <div class="empty-icon">◫</div>
          <p>Select a property to view financial analytics.</p>
        </div>
      </div>

      <transition name="slide">
        <div v-if="message" :class="['message', `message-${message.type}`]">
          {{ message.text }}
        </div>
      </transition>

      <div v-if="showDetailsModal" class="modal" @click.self="showDetailsModal = false">
        <div class="modal-content glass-card">
          <button class="modal-close" @click="showDetailsModal = false">×</button>

          <div class="detail-hero" :style="{ backgroundImage: `url(${generatePropertyImage(detailsProperty || {})})` }">
            <div class="media-overlay"></div>
            <div class="detail-hero-content">
              <p class="section-kicker light">Property details</p>
              <h3>{{ detailsProperty?.address }}</h3>
              <p>{{ detailsProperty?.city }}, {{ detailsProperty?.state }} {{ detailsProperty?.postal_code }}</p>
            </div>
          </div>

          <div class="modal-details">
            <p><strong>Property ID:</strong> {{ detailsProperty?.property_id }}</p>
            <p><strong>Type:</strong> {{ detailsProperty?.property_type || '—' }}</p>
            <p><strong>Tenant:</strong> {{ detailsProperty?.tenant_name || 'Vacant' }}</p>
            <p><strong>Monthly Rent:</strong> ${{ detailsProperty?.monthly_rent }}</p>

            <hr />

            <h4>Income ({{ propertyIncomeForDetails.length }})</h4>
            <div v-if="propertyIncomeForDetails.length === 0" class="sub-empty">No income records</div>
            <div v-else class="record-list">
              <div v-for="inc in propertyIncomeForDetails" :key="inc.income_id" class="record-item">
                <span>{{ formatDate(inc.date) }}</span>
                <span class="success">${{ inc.amount }}</span>
                <span class="text-muted">{{ inc.income_description }}</span>
              </div>
            </div>

            <h4 style="margin-top: 24px;">Expenses ({{ propertyExpensesForDetails.length }})</h4>
            <div v-if="propertyExpensesForDetails.length === 0" class="sub-empty">No expense records</div>
            <div v-else class="record-list">
              <div v-for="exp in propertyExpensesForDetails" :key="exp.expense_id" class="record-item">
                <span>{{ formatDate(exp.date) }}</span>
                <span class="danger">${{ exp.amount }}</span>
                <span class="text-muted">{{ exp.expense_description }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'

const activeTab = ref('properties')
const properties = ref([])
const incomeRecords = ref([])
const expenseRecords = ref([])
const message = ref(null)
const editingProperty = ref(null)
const showDetailsModal = ref(false)
const detailsProperty = ref(null)
const propertyIncomeForDetails = ref([])
const propertyExpensesForDetails = ref([])

const selectedPropertyForIncome = ref('')
const selectedPropertyForExpense = ref('')
const selectedPropertyForAnalytics = ref('')

const newProperty = ref({
  address: '',
  city: '',
  state: '',
  postal_code: '',
  property_type: '',
  monthly_rent: '',
  tenant_name: ''
})

const newIncome = ref({
  amount: '',
  date: '',
  description: ''
})

const newExpense = ref({
  amount: '',
  date: '',
  description: ''
})

const API_BASE_URL = 'https://prop-mgmt-api-807815759229.us-central1.run.app'

function formatDate(dateString) {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

function showMessage(text, type = 'success') {
  message.value = { text, type }
  setTimeout(() => {
    message.value = null
  }, 3000)
}

function resetForms() {
  newProperty.value = {
    address: '',
    city: '',
    state: '',
    postal_code: '',
    property_type: '',
    monthly_rent: '',
    tenant_name: ''
  }
  newIncome.value = { amount: '', date: '', description: '' }
  newExpense.value = { amount: '', date: '', description: '' }
}

function stringToSeed(input = '') {
  return String(input)
    .split('')
    .reduce((acc, char) => acc + char.charCodeAt(0), 0)
}

function generatePropertyImage(property) {
  const descriptor = `${property?.address || ''} ${property?.city || ''} ${property?.property_type || ''}`
  const seed = stringToSeed(descriptor)
  const sky = ['#1f2b34', '#22323a', '#263741', '#1d2a31'][seed % 4]
  const ground = ['#332b24', '#3a3128', '#302821', '#40362b'][seed % 4]
  const house = ['#6f6255', '#7b6b5d', '#66594d', '#857565'][seed % 4]
  const roof = ['#b39568', '#c2a87d', '#9f8460', '#c0a16e'][seed % 4]
  const accent = ['#4c6575', '#57707f', '#425866', '#617c8b'][seed % 4]
  const windows = ['#eadfcd', '#f2e6d5', '#e8dbc8', '#efe4d4'][seed % 4]

  const svg = `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 480">
      <defs>
        <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="${sky}" />
          <stop offset="100%" stop-color="#121212" />
        </linearGradient>
        <linearGradient id="ground" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0%" stop-color="${ground}" />
          <stop offset="100%" stop-color="#1c1c1c" />
        </linearGradient>
      </defs>
      <rect width="800" height="480" fill="url(#sky)" />
      <circle cx="652" cy="94" r="42" fill="#d4bc92" opacity="0.22" />
      <rect y="332" width="800" height="148" fill="url(#ground)" />
      <rect x="96" y="298" width="608" height="24" rx="12" fill="#8c7358" opacity="0.22"/>
      <rect x="206" y="180" width="388" height="156" rx="10" fill="${house}" />
      <polygon points="180,208 400,96 620,208" fill="${roof}" />
      <rect x="370" y="238" width="70" height="98" rx="6" fill="${accent}" />
      <rect x="252" y="226" width="72" height="58" rx="6" fill="${windows}" />
      <rect x="478" y="226" width="72" height="58" rx="6" fill="${windows}" />
      <rect x="115" y="244" width="74" height="92" rx="8" fill="#4a4036" opacity="0.9" />
      <circle cx="140" cy="272" r="26" fill="#5c7667" />
      <circle cx="164" cy="262" r="24" fill="#496253" />
      <circle cx="157" cy="287" r="22" fill="#718b7a" />
      <rect x="154" y="286" width="9" height="50" rx="4" fill="#4a4036" />
      <rect x="605" y="246" width="74" height="90" rx="8" fill="#4a4036" opacity="0.9" />
      <circle cx="629" cy="272" r="24" fill="#5c7667" />
      <circle cx="652" cy="262" r="22" fill="#496253" />
      <circle cx="645" cy="286" r="20" fill="#718b7a" />
      <rect x="640" y="286" width="9" height="50" rx="4" fill="#4a4036" />
      <text x="400" y="434" text-anchor="middle" font-family="Arial, sans-serif" font-size="24" fill="#dbc29a" opacity="0.72">
        ${String(property?.property_type || 'Property').slice(0, 20)}
      </text>
    </svg>
  `

  return `data:image/svg+xml;charset=UTF-8,${encodeURIComponent(svg)}`
}

async function loadProperties() {
  try {
    const response = await fetch(`${API_BASE_URL}/properties`)
    if (!response.ok) throw new Error('Failed to fetch properties')
    properties.value = await response.json()
  } catch (error) {
    console.error('Error loading properties:', error)
    showMessage('Failed to load properties', 'error')
  }
}

async function saveProperty() {
  if (!newProperty.value.address || !newProperty.value.city || !newProperty.value.state) {
    showMessage('Please fill in all required fields', 'error')
    return
  }

  const isEditing = !!editingProperty.value

  try {
    const url = isEditing
      ? `${API_BASE_URL}/properties/${editingProperty.value.property_id}`
      : `${API_BASE_URL}/properties`

    const method = isEditing ? 'PUT' : 'POST'

    const response = await fetch(url, {
      method,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        address: newProperty.value.address,
        city: newProperty.value.city,
        state: newProperty.value.state,
        postal_code: newProperty.value.postal_code,
        property_type: newProperty.value.property_type,
        monthly_rent: newProperty.value.monthly_rent || 0,
        tenant_name: newProperty.value.tenant_name
      })
    })

    if (!response.ok) throw new Error('Failed to save property')

    await loadProperties()
    resetForms()
    editingProperty.value = null
    showMessage(isEditing ? 'Property updated!' : 'Property added!')
  } catch (error) {
    console.error('Error saving property:', error)
    showMessage('Failed to save property', 'error')
  }
}

function editPropertyRecord(property) {
  editingProperty.value = property
  newProperty.value = { ...property }
}

function cancelEdit() {
  editingProperty.value = null
  resetForms()
}

async function deletePropertyRecord(propertyId) {
  if (!confirm('Are you sure you want to delete this property?')) return

  try {
    const response = await fetch(`${API_BASE_URL}/properties/${propertyId}`, {
      method: 'DELETE'
    })

    if (!response.ok) throw new Error('Failed to delete property')

    await loadProperties()
    showMessage('Property deleted!')
  } catch (error) {
    console.error('Error deleting property:', error)
    showMessage('Failed to delete property', 'error')
  }
}

async function viewPropertyDetails(propertyId) {
  const property = properties.value.find(p => p.property_id === propertyId)
  detailsProperty.value = property

  try {
    const [incomeRes, expenseRes] = await Promise.all([
      fetch(`${API_BASE_URL}/properties/${propertyId}/income`),
      fetch(`${API_BASE_URL}/properties/${propertyId}/expenses`)
    ])

    if (!incomeRes.ok || !expenseRes.ok) throw new Error('Failed to fetch details')

    propertyIncomeForDetails.value = await incomeRes.json()
    propertyExpensesForDetails.value = await expenseRes.json()
    showDetailsModal.value = true
  } catch (error) {
    console.error('Error loading property details:', error)
    showMessage('Failed to load property details', 'error')
  }
}

async function loadIncomeRecords() {
  if (!selectedPropertyForIncome.value) {
    incomeRecords.value = []
    return
  }

  try {
    const response = await fetch(`${API_BASE_URL}/properties/${selectedPropertyForIncome.value}/income`)
    if (!response.ok) throw new Error('Failed to fetch income')
    incomeRecords.value = await response.json()
  } catch (error) {
    console.error('Error loading income:', error)
    showMessage('Failed to load income records', 'error')
  }
}

async function addIncome() {
  if (!selectedPropertyForIncome.value || !newIncome.value.amount || !newIncome.value.date) {
    showMessage('Please fill in all required fields', 'error')
    return
  }

  try {
    const response = await fetch(`${API_BASE_URL}/properties/${selectedPropertyForIncome.value}/income`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        amount: newIncome.value.amount,
        date: newIncome.value.date,
        description: newIncome.value.description || 'Income'
      })
    })

    if (!response.ok) throw new Error('Failed to add income')

    newIncome.value = { amount: '', date: '', description: '' }
    await loadIncomeRecords()
    showMessage('Income record added!')
  } catch (error) {
    console.error('Error adding income:', error)
    showMessage('Failed to add income record', 'error')
  }
}

async function loadExpenseRecords() {
  if (!selectedPropertyForExpense.value) {
    expenseRecords.value = []
    return
  }

  try {
    const response = await fetch(`${API_BASE_URL}/properties/${selectedPropertyForExpense.value}/expenses`)
    if (!response.ok) throw new Error('Failed to fetch expenses')
    expenseRecords.value = await response.json()
  } catch (error) {
    console.error('Error loading expenses:', error)
    showMessage('Failed to load expense records', 'error')
  }
}

async function addExpense() {
  if (!selectedPropertyForExpense.value || !newExpense.value.amount || !newExpense.value.date) {
    showMessage('Please fill in all required fields', 'error')
    return
  }

  try {
    const response = await fetch(`${API_BASE_URL}/properties/${selectedPropertyForExpense.value}/expenses`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        amount: newExpense.value.amount,
        date: newExpense.value.date,
        description: newExpense.value.description || 'Expense'
      })
    })

    if (!response.ok) throw new Error('Failed to add expense')

    newExpense.value = { amount: '', date: '', description: '' }
    await loadExpenseRecords()
    showMessage('Expense record added!')
  } catch (error) {
    console.error('Error adding expense:', error)
    showMessage('Failed to add expense record', 'error')
  }
}

function calculateTotalIncome() {
  return incomeRecords.value.reduce((sum, inc) => sum + (inc.amount || 0), 0).toFixed(2)
}

function calculateTotalExpenses() {
  return expenseRecords.value.reduce((sum, exp) => sum + (exp.amount || 0), 0).toFixed(2)
}

function calculateTotalIncomeForProperty() {
  return propertyIncomeForDetails.value.reduce((sum, inc) => sum + (inc.amount || 0), 0).toFixed(2)
}

function calculateTotalExpensesForProperty() {
  return propertyExpensesForDetails.value.reduce((sum, exp) => sum + (exp.amount || 0), 0).toFixed(2)
}

function getPropertyMonthlyRent(propertyIdRef) {
  const propertyId = typeof propertyIdRef === 'object' ? propertyIdRef.value : propertyIdRef
  const prop = properties.value.find(p => p.property_id === propertyId)
  return prop?.monthly_rent || 0
}

const netIncome = computed(() => {
  const income = parseFloat(calculateTotalIncomeForProperty()) || 0
  const expenses = parseFloat(calculateTotalExpensesForProperty()) || 0
  return (income - expenses).toFixed(2)
})

watch(selectedPropertyForIncome, () => {
  loadIncomeRecords()
})

watch(selectedPropertyForExpense, () => {
  loadExpenseRecords()
})

watch(selectedPropertyForAnalytics, async () => {
  propertyIncomeForDetails.value = []
  propertyExpensesForDetails.value = []

  if (!selectedPropertyForAnalytics.value) return

  try {
    const [incomeRes, expenseRes] = await Promise.all([
      fetch(`${API_BASE_URL}/properties/${selectedPropertyForAnalytics.value}/income`),
      fetch(`${API_BASE_URL}/properties/${selectedPropertyForAnalytics.value}/expenses`)
    ])

    if (!incomeRes.ok || !expenseRes.ok) throw new Error('Failed to fetch analytics details')

    propertyIncomeForDetails.value = await incomeRes.json()
    propertyExpensesForDetails.value = await expenseRes.json()
  } catch (error) {
    console.error('Error loading analytics details:', error)
    showMessage('Failed to load analytics', 'error')
  }
})

onMounted(() => {
  loadProperties()
})
</script>

<style scoped>
* {
  box-sizing: border-box;
}

:root {
  --bg: #121212;
  --bg-soft: #181818;
  --surface: rgba(28, 28, 28, 0.85);
  --surface-strong: rgba(34, 34, 34, 0.95);
  --border: rgba(200, 180, 150, 0.12);
  --border-strong: rgba(200, 180, 150, 0.22);
  --text: #eae6df;
  --muted: #b7aa98;
  --muted-soft: #8f8578;
  --primary: #c2a87d;
  --primary-strong: #a78d63;
  --accent-blue: #3e5a6b;
  --accent-blue-soft: #6e8796;
  --success: #6f8f7a;
  --danger: #a36a5f;
  --shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
  --shadow-soft: 0 10px 30px rgba(0, 0, 0, 0.35);
  --radius-xl: 26px;
  --radius-lg: 20px;
  --radius-md: 14px;
}

.portal-shell {
  position: relative;
  min-height: 100vh;
  background:
    radial-gradient(circle at top left, rgba(194, 168, 125, 0.08), transparent 30%),
    radial-gradient(circle at right center, rgba(62, 90, 107, 0.12), transparent 28%),
    linear-gradient(180deg, #171717 0%, #101010 100%);
  overflow: hidden;
}

.ambient {
  position: absolute;
  border-radius: 999px;
  filter: blur(20px);
  pointer-events: none;
}

.ambient-1 {
  width: 360px;
  height: 360px;
  background: rgba(194, 168, 125, 0.06);
  top: -80px;
  right: -80px;
}

.ambient-2 {
  width: 280px;
  height: 280px;
  background: rgba(62, 90, 107, 0.1);
  bottom: 40px;
  left: -60px;
}

.app-container {
  position: relative;
  z-index: 1;
  max-width: 1380px;
  margin: 0 auto;
  padding: 32px;
  min-height: 100vh;
  color: var(--text);
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 20px;
  margin-bottom: 28px;
}

.eyebrow,
.section-kicker {
  margin: 0 0 8px 0;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: var(--muted-soft);
}

.section-kicker.light {
  color: rgba(255, 255, 255, 0.8);
}

h1 {
  margin: 0;
  font-size: clamp(2rem, 3vw, 3rem);
  line-height: 1.05;
  letter-spacing: -0.03em;
  color: var(--text);
}

.page-subtitle {
  margin: 12px 0 0 0;
  max-width: 680px;
  color: var(--muted);
  font-size: 15px;
}

.header-chip {
  padding: 12px 16px;
  border: 1px solid var(--border);
  background: rgba(36, 36, 36, 0.75);
  backdrop-filter: blur(10px);
  border-radius: 999px;
  color: var(--muted);
  font-weight: 600;
  white-space: nowrap;
}

.glass-card {
  background: var(--surface);
  backdrop-filter: blur(16px);
  border: 1px solid var(--border);
  box-shadow: var(--shadow-soft);
}

.nav-tabs {
  display: inline-flex;
  flex-wrap: wrap;
  gap: 8px;
  padding: 8px;
  margin-bottom: 30px;
  background: rgba(30, 30, 30, 0.75);
  border: 1px solid var(--border);
  backdrop-filter: blur(14px);
  border-radius: 999px;
}

.nav-tabs button {
  padding: 12px 18px;
  border: none;
  background: transparent;
  color: var(--muted);
  border-radius: 999px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 600;
  transition: all 0.2s ease;
}

.nav-tabs button:hover {
  background: rgba(194, 168, 125, 0.08);
  color: var(--text);
}

.nav-tabs button.active {
  background: var(--primary);
  color: #171717;
  box-shadow: 0 10px 20px rgba(194, 168, 125, 0.18);
}

.tab-content {
  animation: fadeIn 0.25s ease;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(6px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.section-header {
  margin-bottom: 18px;
}

h2 {
  margin: 0;
  font-size: 1.7rem;
  letter-spacing: -0.03em;
  color: var(--text);
}

h3 {
  margin: 0;
  font-size: 1.15rem;
  color: var(--text);
  letter-spacing: -0.02em;
}

h4 {
  margin: 0 0 10px 0;
  color: var(--text);
}

.card-title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18px;
}

.form-card,
.summary-card,
.analytics-card,
.empty-state,
.modal-content {
  border-radius: var(--radius-xl);
}

.form-card {
  padding: 24px;
  margin-bottom: 24px;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.compact-grid {
  margin-bottom: 16px;
}

.span-2 {
  grid-column: span 2;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.form-card input,
.form-card select,
.form-card textarea,
.select-large {
  width: 100%;
  padding: 14px 16px;
  border-radius: 14px;
  border: 1px solid rgba(200, 180, 150, 0.12);
  background: rgba(38, 38, 38, 0.92);
  color: var(--text);
  font-size: 14px;
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
}

.form-card input::placeholder,
.form-card textarea::placeholder {
  color: var(--muted-soft);
}

.form-card input:focus,
.form-card select:focus,
.form-card textarea:focus,
.select-large:focus {
  outline: none;
  border-color: rgba(194, 168, 125, 0.4);
  box-shadow: 0 0 0 4px rgba(194, 168, 125, 0.08);
}

.button-group {
  display: flex;
  gap: 12px;
  margin-top: 18px;
}

.btn-primary,
.btn-secondary,
.btn-small {
  border: none;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
  font-weight: 600;
}

.btn-primary {
  padding: 13px 18px;
  border-radius: 14px;
  background: var(--primary);
  color: #171717;
  box-shadow: 0 12px 24px rgba(194, 168, 125, 0.22);
}

.btn-primary:hover {
  transform: translateY(-1px);
  background: var(--primary-strong);
  color: #111;
}

.btn-secondary {
  padding: 13px 18px;
  border-radius: 14px;
  background: rgba(255, 255, 255, 0.06);
  color: var(--text);
}

.btn-secondary:hover {
  background: rgba(255, 255, 255, 0.1);
}

.inline-button {
  min-width: 180px;
}

.properties-grid,
.records-grid,
.analytics-dashboard {
  display: grid;
  gap: 22px;
}

.properties-grid {
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
}

.records-grid {
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
}

.analytics-dashboard {
  margin-top: 28px;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
}

.property-card,
.record-card,
.analytics-card {
  overflow: hidden;
  border-radius: var(--radius-xl);
}

.property-card {
  display: flex;
  flex-direction: column;
}

.property-media {
  position: relative;
  min-height: 220px;
  padding: 16px;
  background-size: cover;
  background-position: center;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.media-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(18, 18, 18, 0.12) 0%, rgba(18, 18, 18, 0.66) 100%);
}

.media-top-row,
.media-bottom-row,
.detail-hero-content {
  position: relative;
  z-index: 1;
}

.media-top-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 10px;
}

.property-badge,
.property-id {
  display: inline-flex;
  align-items: center;
  padding: 7px 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
  backdrop-filter: blur(10px);
}

.property-badge {
  background: rgba(194, 168, 125, 0.9);
  color: #171717;
}

.property-id {
  background: rgba(15, 15, 15, 0.42);
  color: rgba(255, 255, 255, 0.92);
}

.media-bottom-row h3 {
  color: white;
  font-size: 1.28rem;
  margin-bottom: 6px;
}

.media-bottom-row p {
  margin: 0;
  color: rgba(255, 255, 255, 0.82);
  font-size: 14px;
}

.card-details {
  padding: 18px 18px 10px;
}

.metric-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 10px 0;
  border-bottom: 1px solid rgba(200, 180, 150, 0.08);
  font-size: 14px;
}

.metric-row:last-child {
  border-bottom: none;
}

.metric-row span {
  color: var(--muted);
}

.metric-row strong {
  color: var(--text);
}

.money {
  font-size: 1rem;
}

.card-actions {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  padding: 0 18px 18px;
}

.btn-small {
  padding: 11px 12px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.06);
  color: var(--text);
}

.btn-small:hover {
  transform: translateY(-1px);
  background: rgba(255, 255, 255, 0.1);
}

.btn-accent {
  background: var(--accent-blue);
  color: white;
}

.btn-accent:hover {
  background: var(--accent-blue-soft);
}

.btn-danger {
  background: rgba(163, 106, 95, 0.16);
  color: #e2c0b7;
}

.btn-danger:hover {
  background: rgba(163, 106, 95, 0.24);
}

.record-card,
.analytics-card,
.summary-card {
  padding: 20px;
}

.record-card.income {
  border: 1px solid rgba(111, 143, 122, 0.18);
}

.record-card.expense {
  border: 1px solid rgba(163, 106, 95, 0.18);
}

.record-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: var(--muted-soft);
  font-size: 12px;
  margin-bottom: 14px;
}

.record-id {
  font-weight: 700;
  color: var(--text);
}

.record-date {
  color: var(--muted-soft);
}

.record-amount {
  margin: 0 0 8px 0;
  font-size: 2rem;
  font-weight: 700;
  letter-spacing: -0.03em;
  color: var(--text);
}

.record-card.income .record-amount,
.analytics-value.success,
.highlight.success,
.success {
  color: var(--success);
}

.record-card.expense .record-amount,
.analytics-value.danger,
.highlight.danger,
.danger {
  color: var(--danger);
}

.record-description,
.analytics-subtitle,
.summary-card p,
.modal-details p,
.sub-empty,
.text-muted {
  color: var(--muted);
}

.analytics-card h4 {
  margin-bottom: 12px;
  color: var(--muted);
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.analytics-value {
  margin: 0;
  font-size: 2.15rem;
  font-weight: 700;
  letter-spacing: -0.04em;
  color: var(--text);
}

.empty-state {
  padding: 56px 22px;
  text-align: center;
}

.empty-icon {
  font-size: 28px;
  color: var(--muted-soft);
  margin-bottom: 12px;
}

.empty-state p {
  margin: 0;
  color: var(--muted);
}

.modal {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(6px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  z-index: 1000;
}

.modal-content {
  position: relative;
  width: min(760px, 100%);
  max-height: 86vh;
  overflow-y: auto;
  padding: 18px;
  background: var(--surface-strong);
}

.modal-close {
  position: absolute;
  top: 16px;
  right: 16px;
  width: 38px;
  height: 38px;
  border-radius: 999px;
  border: none;
  background: rgba(255, 255, 255, 0.08);
  color: var(--text);
  font-size: 24px;
  cursor: pointer;
  z-index: 3;
}

.detail-hero {
  position: relative;
  min-height: 210px;
  padding: 20px;
  border-radius: 20px;
  background-size: cover;
  background-position: center;
  display: flex;
  align-items: end;
  margin-bottom: 20px;
  overflow: hidden;
}

.detail-hero-content h3,
.detail-hero-content p {
  position: relative;
  margin: 0;
  color: white;
}

.detail-hero-content h3 {
  font-size: 1.55rem;
  margin-bottom: 6px;
}

.modal-details {
  padding: 4px 6px 8px;
}

.modal-details hr {
  border: none;
  border-top: 1px solid rgba(200, 180, 150, 0.12);
  margin: 22px 0;
}

.record-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.record-item {
  display: grid;
  grid-template-columns: 110px 90px 1fr;
  gap: 12px;
  align-items: center;
  padding: 12px 14px;
  border-radius: 14px;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(200, 180, 150, 0.08);
  font-size: 13px;
}

.message {
  position: fixed;
  top: 22px;
  right: 22px;
  padding: 14px 18px;
  border-radius: 14px;
  color: white;
  font-weight: 600;
  z-index: 1002;
  box-shadow: var(--shadow);
}

.message-success {
  background: var(--success);
}

.message-error {
  background: var(--danger);
}

.slide-enter-active,
.slide-leave-active {
  transition: all 0.28s ease;
}

.slide-enter-from,
.slide-leave-to {
  transform: translateY(-12px);
  opacity: 0;
}

@media (max-width: 900px) {
  .page-header {
    flex-direction: column;
  }

  .form-grid {
    grid-template-columns: 1fr;
  }

  .span-2 {
    grid-column: span 1;
  }

  .card-actions {
    grid-template-columns: 1fr;
  }

  .record-item {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 640px) {
  .app-container {
    padding: 20px;
  }

  .nav-tabs {
    width: 100%;
    border-radius: 22px;
  }

  .nav-tabs button {
    flex: 1 1 calc(50% - 8px);
  }

  .properties-grid,
  .records-grid,
  .analytics-dashboard {
    grid-template-columns: 1fr;
  }

  .property-media {
    min-height: 200px;
  }
}
</style>
