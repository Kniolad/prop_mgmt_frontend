<template>
  <div class="app-container">
    <h1>🏠 Property Manager</h1>
    
    <!-- Navigation Tabs -->
    <div class="nav-tabs">
      <button 
        @click="activeTab = 'properties'" 
        :class="{ active: activeTab === 'properties' }">
        Properties
      </button>
      <button 
        @click="activeTab = 'income'" 
        :class="{ active: activeTab === 'income' }">
        Income
      </button>
      <button 
        @click="activeTab = 'expenses'" 
        :class="{ active: activeTab === 'expenses' }">
        Expenses
      </button>
      <button 
        @click="activeTab = 'analytics'" 
        :class="{ active: activeTab === 'analytics' }">
        Analytics
      </button>
    </div>

    <!-- PROPERTIES TAB -->
    <div v-if="activeTab === 'properties'" class="tab-content">
      <h2>Properties</h2>
      
      <!-- Add/Edit Property Form -->
      <div class="form-card">
        <h3>{{ editingProperty ? 'Edit Property' : 'Add New Property' }}</h3>
        <div class="form-group">
          <input v-model="newProperty.address" placeholder="Address" />
          <input v-model="newProperty.city" placeholder="City" />
          <input v-model="newProperty.state" placeholder="State" />
          <input v-model="newProperty.postal_code" placeholder="Postal Code" />
          <input v-model="newProperty.property_type" placeholder="Property Type (e.g., Apartment, House)" />
          <input v-model.number="newProperty.monthly_rent" type="number" placeholder="Monthly Rent" />
          <input v-model="newProperty.tenant_name" placeholder="Tenant Name" />
          
          <div class="button-group">
            <button @click="saveProperty" class="btn-primary">
              {{ editingProperty ? 'Update' : 'Add' }} Property
            </button>
            <button v-if="editingProperty" @click="cancelEdit" class="btn-secondary">
              Cancel
            </button>
          </div>
        </div>
      </div>

      <!-- Properties List -->
      <div v-if="properties.length === 0" class="empty-state">
        No properties found. Add your first property above!
      </div>

      <div v-else class="properties-grid">
        <div v-for="p in properties" :key="p.property_id" class="property-card">
          <div class="card-header">
            <h3>{{ p.address }}</h3>
            <span class="property-id">ID: {{ p.property_id }}</span>
          </div>
          
          <div class="card-details">
            <p><strong>City:</strong> {{ p.city }}, {{ p.state }} {{ p.postal_code || '—' }}</p>
            <p><strong>Type:</strong> {{ p.property_type || '—' }}</p>
            <p><strong>Tenant:</strong> {{ p.tenant_name || 'Vacant' }}</p>
            <p><strong>Monthly Rent:</strong> <span class="highlight">${{ p.monthly_rent || 0 }}</span></p>
          </div>
          
          <div class="card-actions">
            <button @click="editPropertyRecord(p)" class="btn-small btn-edit">Edit</button>
            <button @click="viewPropertyDetails(p.property_id)" class="btn-small btn-info">View Details</button>
            <button @click="deletePropertyRecord(p.property_id)" class="btn-small btn-delete">Delete</button>
          </div>
        </div>
      </div>
    </div>

    <!-- INCOME TAB -->
    <div v-if="activeTab === 'income'" class="tab-content">
      <h2>Income Records</h2>
      
      <!-- Select Property for Income -->
      <div class="form-card">
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

      <!-- Add Income Form -->
      <div v-if="selectedPropertyForIncome" class="form-card">
        <h3>Add Income Record</h3>
        <div class="form-group">
          <input v-model.number="newIncome.amount" type="number" placeholder="Amount" step="0.01" />
          <input v-model="newIncome.date" type="date" />
          <input v-model="newIncome.description" placeholder="Description (e.g., Monthly Rent)" />
          
          <button @click="addIncome" class="btn-primary">Record Income</button>
        </div>
      </div>

      <!-- Income Records List -->
      <div v-if="!selectedPropertyForIncome" class="empty-state">
        Select a property to view and add income records
      </div>

      <div v-else-if="incomeRecords.length === 0" class="empty-state">
        No income records for this property
      </div>

      <div v-else class="records-grid">
        <div v-for="inc in incomeRecords" :key="inc.income_id" class="record-card income">
          <div class="record-header">
            <span class="record-id">#{{ inc.income_id }}</span>
            <span class="record-date">{{ formatDate(inc.date) }}</span>
          </div>
          <p class="record-amount">${{ inc.amount }}</p>
          <p class="record-description">{{ inc.income_description || 'No description' }}</p>
        </div>
      </div>

      <!-- Income Summary -->
      <div v-if="selectedPropertyForIncome && incomeRecords.length > 0" class="summary-card">
        <h4>Income Summary</h4>
        <p><strong>Total Income:</strong> <span class="highlight success">${{ calculateTotalIncome() }}</span></p>
        <p><strong>Records Count:</strong> {{ incomeRecords.length }}</p>
      </div>
    </div>

    <!-- EXPENSES TAB -->
    <div v-if="activeTab === 'expenses'" class="tab-content">
      <h2>Expense Records</h2>
      
      <!-- Select Property for Expenses -->
      <div class="form-card">
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

      <!-- Add Expense Form -->
      <div v-if="selectedPropertyForExpense" class="form-card">
        <h3>Add Expense Record</h3>
        <div class="form-group">
          <input v-model.number="newExpense.amount" type="number" placeholder="Amount" step="0.01" />
          <input v-model="newExpense.date" type="date" />
          <input v-model="newExpense.description" placeholder="Description (e.g., Maintenance, Repairs)" />
          
          <button @click="addExpense" class="btn-primary">Record Expense</button>
        </div>
      </div>

      <!-- Expense Records List -->
      <div v-if="!selectedPropertyForExpense" class="empty-state">
        Select a property to view and add expense records
      </div>

      <div v-else-if="expenseRecords.length === 0" class="empty-state">
        No expense records for this property
      </div>

      <div v-else class="records-grid">
        <div v-for="exp in expenseRecords" :key="exp.expense_id" class="record-card expense">
          <div class="record-header">
            <span class="record-id">#{{ exp.expense_id }}</span>
            <span class="record-date">{{ formatDate(exp.date) }}</span>
          </div>
          <p class="record-amount">${{ exp.amount }}</p>
          <p class="record-description">{{ exp.expense_description || 'No description' }}</p>
        </div>
      </div>

      <!-- Expense Summary -->
      <div v-if="selectedPropertyForExpense && expenseRecords.length > 0" class="summary-card">
        <h4>Expense Summary</h4>
        <p><strong>Total Expenses:</strong> <span class="highlight danger">${{ calculateTotalExpenses() }}</span></p>
        <p><strong>Records Count:</strong> {{ expenseRecords.length }}</p>
      </div>
    </div>

    <!-- ANALYTICS TAB -->
    <div v-if="activeTab === 'analytics'" class="tab-content">
      <h2>Financial Analytics</h2>

      <!-- Select Property for Analytics -->
      <div class="form-card">
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

      <!-- Analytics Dashboard -->
      <div v-if="selectedPropertyForAnalytics" class="analytics-dashboard">
        <div class="analytics-card">
          <h4>Total Income</h4>
          <p class="analytics-value success">${{ calculateTotalIncomeForProperty(selectedPropertyForAnalytics) }}</p>
          <p class="analytics-subtitle">All-time income</p>
        </div>

        <div class="analytics-card">
          <h4>Total Expenses</h4>
          <p class="analytics-value danger">${{ calculateTotalExpensesForProperty(selectedPropertyForAnalytics) }}</p>
          <p class="analytics-subtitle">All-time expenses</p>
        </div>

        <div class="analytics-card">
          <h4>Net Income</h4>
          <p class="analytics-value" :class="{ success: netIncome >= 0, danger: netIncome < 0 }">
            ${{ netIncome }}
          </p>
          <p class="analytics-subtitle">Income minus Expenses</p>
        </div>

        <div class="analytics-card">
          <h4>Monthly Rent</h4>
          <p class="analytics-value">${{ getPropertyMonthlyRent(selectedPropertyForAnalytics) }}</p>
          <p class="analytics-subtitle">Recurring revenue</p>
        </div>
      </div>

      <div v-else class="empty-state">
        Select a property to view financial analytics
      </div>
    </div>

    <!-- Notification Messages -->
    <transition name="slide">
      <div v-if="message" :class="['message', `message-${message.type}`]">
        {{ message.text }}
      </div>
    </transition>

    <!-- Property Details Modal -->
    <div v-if="showDetailsModal" class="modal" @click.self="showDetailsModal = false">
      <div class="modal-content">
        <button class="modal-close" @click="showDetailsModal = false">×</button>
        <h3>{{ detailsProperty?.address }}</h3>
        <div class="modal-details">
          <p><strong>Property ID:</strong> {{ detailsProperty?.property_id }}</p>
          <p><strong>Address:</strong> {{ detailsProperty?.address }}, {{ detailsProperty?.city }}, {{ detailsProperty?.state }} {{ detailsProperty?.postal_code }}</p>
          <p><strong>Type:</strong> {{ detailsProperty?.property_type }}</p>
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

          <h4 style="margin-top: 20px;">Expenses ({{ propertyExpensesForDetails.length }})</h4>
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
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'

// State
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

// Selected properties for different tabs
const selectedPropertyForIncome = ref('')
const selectedPropertyForExpense = ref('')
const selectedPropertyForAnalytics = ref('')

// Form data
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

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

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

// ============================================================================
// PROPERTIES ENDPOINTS
// ============================================================================

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

  try {
    const url = editingProperty.value
      ? `${API_BASE_URL}/properties/${editingProperty.value.property_id}`
      : `${API_BASE_URL}/properties`
    
    const method = editingProperty.value ? 'PUT' : 'POST'

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
    showMessage(editingProperty.value ? 'Property updated!' : 'Property added!')
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

// ============================================================================
// INCOME ENDPOINTS
// ============================================================================

async function loadIncomeRecords() {
  if (!selectedPropertyForIncome.value) return

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

// ============================================================================
// EXPENSES ENDPOINTS
// ============================================================================

async function loadExpenseRecords() {
  if (!selectedPropertyForExpense.value) return

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

// ============================================================================
// ANALYTICS & COMPUTED VALUES
// ============================================================================

function calculateTotalIncome() {
  return incomeRecords.value.reduce((sum, inc) => sum + (inc.amount || 0), 0).toFixed(2)
}

function calculateTotalExpenses() {
  return expenseRecords.value.reduce((sum, exp) => sum + (exp.amount || 0), 0).toFixed(2)
}

function calculateTotalIncomeForProperty(propertyId) {
  return propertyIncomeForDetails.value.reduce((sum, inc) => sum + (inc.amount || 0), 0).toFixed(2)
}

function calculateTotalExpensesForProperty(propertyId) {
  return propertyExpensesForDetails.value.reduce((sum, exp) => sum + (exp.amount || 0), 0).toFixed(2)
}

function getPropertyMonthlyRent(propertyId) {
  const prop = properties.value.find(p => p.property_id === propertyId)
  return prop?.monthly_rent || 0
}

const netIncome = computed(() => {
  const income = parseFloat(calculateTotalIncomeForProperty(selectedPropertyForAnalytics.value)) || 0
  const expenses = parseFloat(calculateTotalExpensesForProperty(selectedPropertyForAnalytics.value)) || 0
  return (income - expenses).toFixed(2)
})

// ============================================================================
// WATCHERS & LIFECYCLE
// ============================================================================

watch(selectedPropertyForIncome, () => {
  loadIncomeRecords()
})

watch(selectedPropertyForExpense, () => {
  loadExpenseRecords()
})

watch(selectedPropertyForAnalytics, () => {
  propertyIncomeForDetails.value = []
  propertyExpensesForDetails.value = []
  
  if (selectedPropertyForAnalytics.value) {
    loadIncomeRecords()
    loadExpenseRecords()
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
  --primary: #007bff;
  --success: #28a745;
  --danger: #dc3545;
  --warning: #ffc107;
  --info: #17a2b8;
  --dark: #343a40;
  --light: #f8f9fa;
  --border: #dee2e6;
}

.app-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
  background-color: var(--light);
  min-height: 100vh;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

h1 {
  color: var(--dark);
  text-align: center;
  margin-bottom: 30px;
  font-size: 32px;
}

h2 {
  color: var(--dark);
  margin-bottom: 20px;
  border-bottom: 2px solid var(--primary);
  padding-bottom: 10px;
}

h3 {
  margin: 0;
  color: var(--dark);
}

h4 {
  color: var(--dark);
  margin-top: 15px;
  margin-bottom: 10px;
}

/* Navigation Tabs */
.nav-tabs {
  display: flex;
  gap: 10px;
  margin-bottom: 30px;
  border-bottom: 2px solid var(--border);
  background: white;
  padding: 0;
  border-radius: 4px;
  overflow: hidden;
}

.nav-tabs button {
  padding: 12px 24px;
  border: none;
  background-color: transparent;
  cursor: pointer;
  font-size: 15px;
  font-weight: 500;
  color: #666;
  transition: all 0.3s ease;
  border-bottom: 3px solid transparent;
  margin-bottom: -2px;
}

.nav-tabs button:hover {
  color: var(--primary);
  background-color: rgba(0, 123, 255, 0.05);
}

.nav-tabs button.active {
  color: var(--primary);
  border-bottom-color: var(--primary);
}

.tab-content {
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(5px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Forms */
.form-card {
  background: white;
  padding: 24px;
  border-radius: 8px;
  margin-bottom: 24px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  border: 1px solid var(--border);
}

.form-card h3 {
  margin-top: 0;
  margin-bottom: 20px;
  color: var(--dark);
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.form-group input,
.form-group select,
.form-group textarea {
  padding: 12px;
  border: 1px solid var(--border);
  border-radius: 6px;
  font-size: 14px;
  font-family: inherit;
  background: white;
  transition: all 0.2s ease;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
}

.form-group textarea {
  resize: vertical;
  min-height: 80px;
}

.select-large {
  padding: 12px;
  border: 1px solid var(--border);
  border-radius: 6px;
  font-size: 14px;
  background: white;
  cursor: pointer;
}

.select-large:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
}

.button-group {
  display: flex;
  gap: 10px;
  margin-top: 10px;
}

/* Buttons */
.btn-primary,
.btn-secondary,
.btn-small,
.btn-info {
  padding: 10px 16px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s ease;
}

.btn-primary {
  background-color: var(--primary);
  color: white;
  flex: 1;
}

.btn-primary:hover {
  background-color: #0056b3;
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 123, 255, 0.2);
}

.btn-secondary {
  background-color: #6c757d;
  color: white;
  flex: 1;
}

.btn-secondary:hover {
  background-color: #5a6268;
}

.btn-small {
  padding: 8px 12px;
  font-size: 12px;
  background-color: #e9ecef;
  color: var(--dark);
}

.btn-small:hover {
  background-color: #dee2e6;
}

.btn-edit {
  background-color: var(--info);
  color: white;
}

.btn-edit:hover {
  background-color: #138496;
}

.btn-delete {
  background-color: var(--danger);
  color: white;
}

.btn-delete:hover {
  background-color: #c82333;
}

.btn-info {
  background-color: var(--info);
  color: white;
}

.btn-info:hover {
  background-color: #138496;
}

/* Cards Grid */
.properties-grid,
.records-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.property-card,
.record-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  border: 1px solid var(--border);
  transition: all 0.3s ease;
  overflow: hidden;
}

.property-card:hover,
.record-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.12);
}

.property-card {
  padding: 20px;
  display: flex;
  flex-direction: column;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.card-header h3 {
  margin: 0;
  font-size: 18px;
}

.property-id {
  background: var(--light);
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  color: #666;
  font-weight: 500;
}

.card-details {
  flex: 1;
  margin-bottom: 15px;
}

.card-details p {
  margin: 8px 0;
  font-size: 14px;
  color: #666;
}

.highlight {
  font-weight: 600;
  color: var(--primary);
}

.card-actions {
  display: flex;
  gap: 8px;
  margin-top: auto;
}

.card-actions button {
  flex: 1;
}

/* Record Cards */
.record-card {
  padding: 16px;
  border-left: 4px solid #ccc;
}

.record-card.income {
  border-left-color: var(--success);
}

.record-card.expense {
  border-left-color: var(--danger);
}

.record-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
  font-size: 12px;
  color: #999;
}

.record-id {
  font-weight: 600;
  color: #333;
}

.record-amount {
  font-size: 20px;
  font-weight: 700;
  margin: 10px 0;
  color: var(--dark);
}

.record-card.income .record-amount {
  color: var(--success);
}

.record-card.expense .record-amount {
  color: var(--danger);
}

.record-description {
  margin: 8px 0 0 0;
  font-size: 13px;
  color: #666;
  font-style: italic;
}

/* Empty State */
.empty-state {
  background: white;
  padding: 60px 20px;
  border-radius: 8px;
  text-align: center;
  color: #999;
  font-size: 16px;
  border: 1px solid var(--border);
}

/* Summary Card */
.summary-card {
  background: white;
  padding: 20px;
  border-radius: 8px;
  border: 1px solid var(--border);
  margin-top: 20px;
}

.summary-card h4 {
  margin-top: 0;
}

.summary-card p {
  margin: 10px 0;
  font-size: 15px;
}

/* Analytics */
.analytics-dashboard {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-top: 30px;
}

.analytics-card {
  background: white;
  padding: 24px;
  border-radius: 8px;
  text-align: center;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  border: 1px solid var(--border);
}

.analytics-card h4 {
  margin: 0 0 15px 0;
  color: #666;
  font-size: 14px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.analytics-value {
  font-size: 32px;
  font-weight: 700;
  margin: 10px 0;
}

.analytics-value.success {
  color: var(--success);
}

.analytics-value.danger {
  color: var(--danger);
}

.analytics-subtitle {
  margin: 10px 0 0 0;
  font-size: 12px;
  color: #999;
}

/* Modal */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal-content {
  background: white;
  border-radius: 8px;
  padding: 30px;
  max-width: 600px;
  width: 100%;
  max-height: 80vh;
  overflow-y: auto;
  position: relative;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.modal-close {
  position: absolute;
  top: 15px;
  right: 15px;
  background: none;
  border: none;
  font-size: 28px;
  color: #999;
  cursor: pointer;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-close:hover {
  color: var(--dark);
}

.modal-details {
  color: #333;
}

.modal-details p {
  margin: 10px 0;
  font-size: 14px;
}

.modal-details hr {
  margin: 20px 0;
  border: none;
  border-top: 1px solid var(--border);
}

.sub-empty {
  color: #999;
  font-style: italic;
  padding: 10px;
}

.record-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.record-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  background: var(--light);
  border-radius: 4px;
  font-size: 13px;
}

.record-item span:nth-child(1) {
  color: #999;
  min-width: 90px;
}

.record-item span.success {
  color: var(--success);
  font-weight: 600;
}

.record-item span.danger {
  color: var(--danger);
  font-weight: 600;
}

.record-item span.text-muted {
  color: #999;
  margin-left: auto;
  text-align: right;
  flex-grow: 1;
}

/* Messages */
.message {
  position: fixed;
  top: 20px;
  right: 20px;
  padding: 16px 20px;
  border-radius: 6px;
  color: white;
  z-index: 1001;
  font-weight: 500;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.message-success {
  background-color: var(--success);
}

.message-error {
  background-color: var(--danger);
}

.slide-enter-active,
.slide-leave-active {
  transition: all 0.3s ease;
}

.slide-enter-from,
.slide-leave-to {
  transform: translateX(400px);
  opacity: 0;
}

/**

    <!-- Tab Navigation -->
    <div class="nav-tabs">
      <button 
        @click="activeTab = 'properties'" 
        :class="{ active: activeTab === 'properties' }">
        Properties
      </button>
      <button 
        @click="activeTab = 'income'" 
        :class="{ active: activeTab === 'income' }">
        Income
      </button>
      <button 
        @click="activeTab = 'expenses'" 
        :class="{ active: activeTab === 'expenses' }">
        Expenses
      </button>
    </div>

    <!-- PROPERTIES TAB -->
    <div v-if="activeTab === 'properties'" class="tab-content">
      <div class="form-card">
        <h2>Add New Property</h2>
        <div class="form-group">
          <input v-model="newName" placeholder="Property name" class="form-input" />
          <input v-model="newAddress" placeholder="Address" class="form-input" />
          <input v-model="newCity" placeholder="City" class="form-input" />
          <input v-model="newState" placeholder="State" class="form-input" />
          <button @click="addProperty" class="btn-primary">Add Property</button>
        </div>
      </div>

      <div v-if="properties.length === 0" class="empty-state">
        No properties found. Add your first property above!
      </div>

      <div v-else class="properties-grid">
        <div v-for="p in properties" :key="p.id" class="property-card">
          <h3>{{ p.name }}</h3>
          <p v-if="p.address"><strong>Address:</strong> {{ p.address }}</p>
          <p v-if="p.city"><strong>City:</strong> {{ p.city }}, {{ p.state }}</p>
        </div>
      </div>
    </div>

    <!-- INCOME TAB -->
    <div v-if="activeTab === 'income'" class="tab-content">
      <div class="form-card">
        <h2>Record Income</h2>
        <div class="form-group">
          <select v-model.number="selectedPropertyForIncome" class="form-input">
            <option value="">-- Select a Property --</option>
            <option v-for="p in properties" :key="p.id" :value="p.id">
              {{ p.name }}
            </option>
          </select>
          
          <input 
            v-model.number="incomeForm.amount" 
            type="number" 
            placeholder="Amount" 
            step="0.01"
            class="form-input" 
          />
          
          <input 
            v-model="incomeForm.date" 
            type="date" 
            class="form-input" 
          />
          
          <input 
            v-model="incomeForm.description" 
            placeholder="Description (e.g., Monthly Rent)" 
            class="form-input" 
          />
          
          <button @click="addIncome" class="btn-primary" :disabled="!selectedPropertyForIncome">
            Record Income
          </button>
        </div>
      </div>

      <div v-if="incomeRecords.length === 0" class="empty-state">
        No income records yet. Add one above!
      </div>

      <div v-else class="records-grid">
        <div v-for="inc in incomeRecords" :key="inc.id" class="record-card income-card">
          <div class="record-header">
            <span class="record-label">Income</span>
            <span class="record-date">{{ formatDate(inc.date) }}</span>
          </div>
          <p class="record-amount income-amount">${{ inc.amount }}</p>
          <p class="record-description">{{ inc.description || 'No description' }}</p>
        </div>
      </div>

      <div v-if="incomeRecords.length > 0" class="summary-card success">
        <h4>Income Summary</h4>
        <p><strong>Total Income:</strong> ${{ calculateTotalIncome() }}</p>
        <p><strong>Records:</strong> {{ incomeRecords.length }}</p>
      </div>
    </div>

    <!-- EXPENSES TAB -->
    <div v-if="activeTab === 'expenses'" class="tab-content">
      <div class="form-card">
        <h2>Record Expense</h2>
        <div class="form-group">
          <select v-model.number="selectedPropertyForExpense" class="form-input">
            <option value="">-- Select a Property --</option>
            <option v-for="p in properties" :key="p.id" :value="p.id">
              {{ p.name }}
            </option>
          </select>
          
          <input 
            v-model.number="expenseForm.amount" 
            type="number" 
            placeholder="Amount" 
            step="0.01"
            class="form-input" 
          />
          
          <input 
            v-model="expenseForm.date" 
            type="date" 
            class="form-input" 
          />
          
          <input 
            v-model="expenseForm.description" 
            placeholder="Description (e.g., Maintenance, Repairs)" 
            class="form-input" 
          />
          
          <button @click="addExpense" class="btn-primary" :disabled="!selectedPropertyForExpense">
            Record Expense
          </button>
        </div>
      </div>

      <div v-if="expenseRecords.length === 0" class="empty-state">
        No expense records yet. Add one above!
      </div>

      <div v-else class="records-grid">
        <div v-for="exp in expenseRecords" :key="exp.id" class="record-card expense-card">
          <div class="record-header">
            <span class="record-label">Expense</span>
            <span class="record-date">{{ formatDate(exp.date) }}</span>
          </div>
          <p class="record-amount expense-amount">${{ exp.amount }}</p>
          <p class="record-description">{{ exp.description || 'No description' }}</p>
        </div>
      </div>

      <div v-if="expenseRecords.length > 0" class="summary-card danger">
        <h4>Expense Summary</h4>
        <p><strong>Total Expenses:</strong> ${{ calculateTotalExpenses() }}</p>
        <p><strong>Records:</strong> {{ expenseRecords.length }}</p>
      </div>
    </div>

    <!-- Notifications -->
    <transition name="slide">
      <div v-if="notification" :class="['notification', `notification-${notification.type}`]">
        {{ notification.message }}
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const API_BASE_URL = 'https://prop-mgmt-api-807815759229.us-central1.run.app'

// Tab State
const activeTab = ref('properties')

// Properties
const properties = ref([])
const newName = ref("")
const newAddress = ref("")
const newCity = ref("")
const newState = ref("")

// Income
const incomeRecords = ref([])
const selectedPropertyForIncome = ref("")
const incomeForm = ref({
  amount: "",
  date: "",
  description: ""
})

// Expenses
const expenseRecords = ref([])
const selectedPropertyForExpense = ref("")
const expenseForm = ref({
  amount: "",
  date: "",
  description: ""
})

// Notifications
const notification = ref(null)

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

function formatDate(dateString) {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

function showNotification(message, type = 'success') {
  notification.value = { message, type }
  setTimeout(() => {
    notification.value = null
  }, 3000)
}

// ============================================================================
// PROPERTIES
// ============================================================================

async function loadProperties() {
  try {
    const res = await fetch(`${API_BASE_URL}/properties`)
    if (!res.ok) throw new Error('Failed to fetch properties')
    properties.value = await res.json()
  } catch (error) {
    console.error('Error loading properties:', error)
    showNotification('Failed to load properties', 'error')
  }
}

async function addProperty() {
  if (!newName.value.trim()) {
    showNotification('Please enter a property name', 'error')
    return
  }

  try {
    const response = await fetch(`${API_BASE_URL}/properties`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        name: newName.value,
        address: newAddress.value || null,
        city: newCity.value || null,
        state: newState.value || null
      })
    })

    if (!response.ok) throw new Error('Failed to add property')

    newName.value = ""
    newAddress.value = ""
    newCity.value = ""
    newState.value = ""
    
    await loadProperties()
    showNotification('Property added successfully!')
  } catch (error) {
    console.error('Error adding property:', error)
    showNotification('Failed to add property', 'error')
  }
}

// ============================================================================
// INCOME
// ============================================================================

async function loadIncomeRecords() {
  if (!selectedPropertyForIncome.value) {
    incomeRecords.value = []
    return
  }

  try {
    const res = await fetch(`${API_BASE_URL}/properties/${selectedPropertyForIncome.value}/income`)
    if (!res.ok) throw new Error('Failed to fetch income')
    incomeRecords.value = await res.json()
  } catch (error) {
    console.error('Error loading income:', error)
    showNotification('Failed to load income records', 'error')
  }
}

async function addIncome() {
  if (!selectedPropertyForIncome.value || !incomeForm.value.amount || !incomeForm.value.date) {
    showNotification('Please fill in all required fields', 'error')
    return
  }

  try {
    const response = await fetch(`${API_BASE_URL}/properties/${selectedPropertyForIncome.value}/income`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        amount: parseFloat(incomeForm.value.amount),
        date: incomeForm.value.date,
        description: incomeForm.value.description || 'Income'
      })
    })

    if (!response.ok) throw new Error('Failed to add income')

    incomeForm.value = { amount: "", date: "", description: "" }
    await loadIncomeRecords()
    showNotification('Income record added successfully!')
  } catch (error) {
    console.error('Error adding income:', error)
    showNotification('Failed to add income record', 'error')
  }
}

function calculateTotalIncome() {
  return incomeRecords.value.reduce((sum, inc) => sum + (inc.amount || 0), 0).toFixed(2)
}

// ============================================================================
// EXPENSES
// ============================================================================

async function loadExpenseRecords() {
  if (!selectedPropertyForExpense.value) {
    expenseRecords.value = []
    return
  }

  try {
    const res = await fetch(`${API_BASE_URL}/properties/${selectedPropertyForExpense.value}/expenses`)
    if (!res.ok) throw new Error('Failed to fetch expenses')
    expenseRecords.value = await res.json()
  } catch (error) {
    console.error('Error loading expenses:', error)
    showNotification('Failed to load expense records', 'error')
  }
}

async function addExpense() {
  if (!selectedPropertyForExpense.value || !expenseForm.value.amount || !expenseForm.value.date) {
    showNotification('Please fill in all required fields', 'error')
    return
  }

  try {
    const response = await fetch(`${API_BASE_URL}/properties/${selectedPropertyForExpense.value}/expenses`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        amount: parseFloat(expenseForm.value.amount),
        date: expenseForm.value.date,
        description: expenseForm.value.description || 'Expense'
      })
    })

    if (!response.ok) throw new Error('Failed to add expense')

    expenseForm.value = { amount: "", date: "", description: "" }
    await loadExpenseRecords()
    showNotification('Expense record added successfully!')
  } catch (error) {
    console.error('Error adding expense:', error)
    showNotification('Failed to add expense record', 'error')
  }
}

function calculateTotalExpenses() {
  return expenseRecords.value.reduce((sum, exp) => sum + (exp.amount || 0), 0).toFixed(2)
}

// ============================================================================
// WATCHERS & LIFECYCLE
// ============================================================================

onMounted(() => {
  loadProperties()
})

// Load records when property is selected using watch-like behavior
import { watch } from 'vue'

watch(selectedPropertyForIncome, () => {
  loadIncomeRecords()
})

watch(selectedPropertyForExpense, () => {
  loadExpenseRecords()
})
</script>

<style scoped>
* {
  box-sizing: border-box;
}

:root {
  --primary: #007bff;
  --success: #28a745;
  --danger: #dc3545;
  --dark: #343a40;
  --light: #f8f9fa;
  --border: #dee2e6;
}

.app-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  background-color: var(--light);
  min-height: 100vh;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

h1 {
  color: var(--dark);
  text-align: center;
  margin-bottom: 30px;
  font-size: 32px;
}

h2 {
  color: var(--dark);
  margin-top: 0;
  margin-bottom: 20px;
}

h3 {
  color: var(--dark);
  margin-top: 0;
}

h4 {
  color: var(--dark);
  margin: 0 0 10px 0;
}

/* Navigation Tabs */
.nav-tabs {
  display: flex;
  gap: 10px;
  margin-bottom: 30px;
  border-bottom: 2px solid var(--border);
  background: white;
  padding: 0;
  border-radius: 4px 4px 0 0;
}

.nav-tabs button {
  padding: 12px 24px;
  border: none;
  background-color: transparent;
  cursor: pointer;
  font-size: 15px;
  font-weight: 500;
  color: #666;
  transition: all 0.3s ease;
  border-bottom: 3px solid transparent;
  margin-bottom: -2px;
}

.nav-tabs button:hover {
  color: var(--primary);
}

.nav-tabs button.active {
  color: var(--primary);
  border-bottom-color: var(--primary);
}

.tab-content {
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(5px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Forms */
.form-card {
  background: white;
  padding: 24px;
  border-radius: 8px;
  margin-bottom: 24px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  border: 1px solid var(--border);
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.form-input {
  padding: 12px;
  border: 1px solid var(--border);
  border-radius: 6px;
  font-size: 14px;
  font-family: inherit;
  background: white;
  transition: all 0.2s ease;
}

.form-input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
}

/* Buttons */
.btn-primary {
  padding: 12px 16px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  background-color: var(--primary);
  color: white;
  transition: all 0.2s ease;
}

.btn-primary:hover:not(:disabled) {
  background-color: #0056b3;
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 123, 255, 0.2);
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Cards */
.properties-grid,
.records-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 24px;
}

.property-card,
.record-card {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  border: 1px solid var(--border);
  transition: all 0.3s ease;
}

.property-card:hover,
.record-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.12);
}

.property-card p {
  margin: 8px 0;
  color: #666;
  font-size: 14px;
}

/* Record Cards */
.record-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  font-size: 12px;
}

.record-label {
  font-weight: 600;
  padding: 4px 8px;
  border-radius: 4px;
  background: #f0f0f0;
}

.record-date {
  color: #999;
}

.record-amount {
  font-size: 24px;
  font-weight: 700;
  margin: 12px 0;
}

.income-card {
  border-left: 4px solid var(--success);
}

.income-amount {
  color: var(--success);
}

.expense-card {
  border-left: 4px solid var(--danger);
}

.expense-amount {
  color: var(--danger);
}

.record-description {
  margin: 8px 0 0 0;
  font-size: 13px;
  color: #666;
  font-style: italic;
}

/* Empty State */
.empty-state {
  background: white;
  padding: 60px 20px;
  border-radius: 8px;
  text-align: center;
  color: #999;
  font-size: 16px;
  border: 1px solid var(--border);
  margin-bottom: 24px;
}

/* Summary Cards */
.summary-card {
  background: white;
  padding: 20px;
  border-radius: 8px;
  border-left: 4px solid;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
}

.summary-card.success {
  border-left-color: var(--success);
}

.summary-card.danger {
  border-left-color: var(--danger);
}

.summary-card p {
  margin: 8px 0;
  color: #666;
  font-size: 14px;
}

/* Notifications */
.notification {
  position: fixed;
  bottom: 20px;
  right: 20px;
  padding: 16px 24px;
  border-radius: 6px;
  color: white;
  font-weight: 500;
  animation: slideUp 0.3s ease;
  z-index: 1000;
}

.notification-success {
  background-color: var(--success);
}

.notification-error {
  background-color: var(--danger);
}

@keyframes slideUp {
  from {
    transform: translateY(100px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.slide-enter-active,
.slide-leave-active {
  transition: all 0.3s ease;
}

.slide-enter-from,
.slide-leave-to {
  transform: translateY(100px);
  opacity: 0;
}
</style>
