// ────────── Auth ──────────
window.doLogin = async () => {
  const email    = document.getElementById('auth-email').value.trim();
  const password = document.getElementById('auth-password').value;
  const errEl    = document.getElementById('auth-error');
  errEl.style.display = 'none';
  try {
    await window._firebase.signInWithEmailAndPassword(window._auth, email, password);
  } catch (e) {
    errEl.textContent = e.message;
    errEl.style.display = 'block';
  }
};

window.doLogout = async () => {
  await window._firebase.signOut(window._auth);
};

// ────────── Navigation ──────────
const PAGE_TITLES = {
  dashboard: 'Dashboard', dentists: 'Dentists',
  appointments: 'Appointments', services: 'Services',
  users: 'Patients', reviews: 'Reviews', statistics: 'Statistics'
};
window.showPage = (name) => {
  document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
  document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
  document.getElementById(`page-${name}`).classList.add('active');
  document.getElementById('page-title').textContent = PAGE_TITLES[name];
  document.querySelectorAll('.nav-item').forEach(n => {
    if (n.textContent.toLowerCase().includes(name === 'users' ? 'patient' : name)) {
      n.classList.add('active');
    }
  });
  const loaders = {
    dashboard: loadDashboard, dentists: loadDentists,
    appointments: loadAppointments, services: loadServices,
    users: loadUsers, reviews: loadReviews, statistics: loadStatistics
  };
  if (loaders[name]) loaders[name]();
};

// ────────── DASHBOARD ──────────
async function loadDashboard() {
  const db_ = window._db;
  const { collection: col, getDocs: gDs, query: q, where: w } = window._firebase;
  try {
    const [users, dentists, appts, reviews] = await Promise.all([
      gDs(q(col(db_, 'users'), w('role', '==', 'patient'))),
      gDs(col(db_, 'dentists')),
      gDs(col(db_, 'appointments')),
      gDs(col(db_, 'reviews')),
    ]);
    const pending  = appts.docs.filter(d => d.data().status === 'Pending').length;
    const today    = appts.docs.filter(d => {
      const t = d.data().date?.toDate?.();
      if (!t) return false;
      const n = new Date(); return t.toDateString() === n.toDateString();
    }).length;
    document.getElementById('stats-grid').innerHTML = `
      <div class="stat-card"><div class="stat-icon">👥</div><div class="stat-value">${users.size}</div><div class="stat-label">Patients</div></div>
      <div class="stat-card"><div class="stat-icon">👨‍⚕️</div><div class="stat-value">${dentists.size}</div><div class="stat-label">Dentists</div></div>
      <div class="stat-card"><div class="stat-icon">📅</div><div class="stat-value">${appts.size}</div><div class="stat-label">Total Appointments</div></div>
      <div class="stat-card"><div class="stat-icon">⏳</div><div class="stat-value">${pending}</div><div class="stat-label">Pending</div></div>
      <div class="stat-card"><div class="stat-icon">📆</div><div class="stat-value">${today}</div><div class="stat-label">Today's Appointments</div></div>
      <div class="stat-card"><div class="stat-icon">⭐</div><div class="stat-value">${reviews.size}</div><div class="stat-label">Reviews</div></div>
    `;
    const sorted = appts.docs.sort((a,b) => (b.data().createdAt?.seconds||0) - (a.data().createdAt?.seconds||0)).slice(0,8);
    document.getElementById('recent-appointments-body').innerHTML = buildApptTable(sorted, true);
  } catch (e) {
    document.getElementById('stats-grid').innerHTML = `<p style="color:var(--error)">${e.message}</p>`;
  }
}
window.loadDashboard = loadDashboard;

// ────────── DENTISTS ──────────
async function loadDentists() {
  const db_ = window._db;
  const { collection: col, getDocs: gDs } = window._firebase;
  const body = document.getElementById('dentists-body');
  body.innerHTML = '<div class="loading"><div class="spinner"></div></div>';
  try {
    const snap = await gDs(col(db_, 'dentists'));
    if (snap.empty) { body.innerHTML = '<p class="loading">No dentists found.</p>'; return; }
    body.innerHTML = `<table>
      <thead><tr><th>Name</th><th>Specialization</th><th>Experience</th><th>Rating</th><th>Working Days</th><th>Actions</th></tr></thead>
      <tbody>${snap.docs.map(d => {
        const dt = d.data();
        return `<tr>
          <td><strong>${esc(dt.name||'')}</strong></td>
          <td>${esc(dt.specialization||'')}</td>
          <td>${dt.experience||0} yrs</td>
          <td><span class="stars">${stars(dt.averageRating||0)}</span> ${(dt.averageRating||0).toFixed(1)}</td>
          <td>${(dt.workingDays||[]).join(', ')}</td>
          <td>
            <button class="btn btn-outline btn-sm" onclick="editDentist('${d.id}')">✏️ Edit</button>
            <button class="btn btn-error btn-sm" onclick="confirmDelete('dentists','${d.id}','dentist ${esc(dt.name||'')}')">🗑️</button>
          </td>
        </tr>`;
      }).join('')}</tbody></table>`;
  } catch (e) {
    body.innerHTML = `<p style="color:var(--error);padding:16px">${e.message}</p>`;
  }
}
window.loadDentists = loadDentists;

window.openDentistModal = (data = null, id = '') => {
  document.getElementById('dentist-modal-title').textContent = id ? 'Edit Dentist' : 'Add Dentist';
  document.getElementById('dentist-id').value   = id;
  document.getElementById('d-name').value  = data?.name  || '';
  document.getElementById('d-spec').value  = data?.specialization || '';
  document.getElementById('d-exp').value   = data?.experience || '';
  document.getElementById('d-img').value   = data?.image || '';
  document.getElementById('d-desc').value  = data?.description || '';
  document.getElementById('d-start').value = data?.workingHours?.start || '09:00';
  document.getElementById('d-end').value   = data?.workingHours?.end || '17:00';
  document.getElementById('d-days').value  = (data?.workingDays||[]).join(',');
  document.getElementById('dentist-modal').classList.remove('hidden');
};

window.editDentist = async (id) => {
  const { doc: dc, getDoc: gDc } = window._firebase;
  const snap = await gDc(dc(window._db, 'dentists', id));
  if (snap.exists()) openDentistModal(snap.data(), id);
};

window.saveDentist = async () => {
  const { collection: col, doc: dc, addDoc: aDc, updateDoc: uDc } = window._firebase;
  const id   = document.getElementById('dentist-id').value;
  const days = document.getElementById('d-days').value.split(',').map(s=>s.trim()).filter(Boolean);
  const data = {
    name:           document.getElementById('d-name').value.trim(),
    specialization: document.getElementById('d-spec').value.trim(),
    experience:     Number(document.getElementById('d-exp').value) || 0,
    image:          document.getElementById('d-img').value.trim(),
    description:    document.getElementById('d-desc').value.trim(),
    workingDays:    days,
    workingHours: {
      start: document.getElementById('d-start').value.trim(),
      end:   document.getElementById('d-end').value.trim(),
    },
  };
  if (!data.name || !data.specialization) { showToast('Name and specialization are required.', 'error'); return; }
  try {
    if (id) {
      await uDc(dc(window._db, 'dentists', id), data);
      showToast('Dentist updated.', 'success');
    } else {
      data.averageRating = 0; data.totalReviews = 0;
      await aDc(col(window._db, 'dentists'), data);
      showToast('Dentist added.', 'success');
    }
    closeModal('dentist-modal');
    loadDentists();
  } catch (e) { showToast(e.message, 'error'); }
};

// ────────── APPOINTMENTS ──────────
async function loadAppointments() {
  const db_ = window._db;
  const { collection: col, getDocs: gDs, query: q, where: w } = window._firebase;
  const body   = document.getElementById('appointments-body');
  const status = document.getElementById('appt-filter-status')?.value || '';
  body.innerHTML = '<div class="loading"><div class="spinner"></div></div>';
  try {
    let qr = col(db_, 'appointments');
    if (status) qr = q(qr, w('status', '==', status));
    const snap = await gDs(qr);
    const sorted = snap.docs.sort((a,b) => (b.data().createdAt?.seconds||0) - (a.data().createdAt?.seconds||0));
    body.innerHTML = buildApptTable(sorted, false);
  } catch (e) {
    body.innerHTML = `<p style="color:var(--error);padding:16px">${e.message}</p>`;
  }
}
window.loadAppointments = loadAppointments;

function buildApptTable(docs, compact) {
  if (!docs.length) return '<p class="loading">No appointments found.</p>';
  return `<table>
    <thead><tr>
      <th>Patient</th><th>Dentist</th><th>Date</th><th>Time</th><th>Status</th>
      ${compact ? '' : '<th>Actions</th>'}
    </tr></thead>
    <tbody>${docs.map(d => {
      const a = d.data();
      const dateStr = a.date?.toDate ? a.date.toDate().toLocaleDateString() : '—';
      return `<tr>
        <td>${esc(a.patientName||'—')}</td>
        <td>${esc(a.dentistName||'—')}</td>
        <td>${dateStr}</td>
        <td>${esc(a.time||'—')}</td>
        <td>${badgeStatus(a.status)}</td>
        ${compact ? '' : `<td>${statusActions(d.id, a.status)}</td>`}
      </tr>`;
    }).join('')}</tbody></table>`;
}

function statusActions(id, status) {
  let html = '';
  if (status === 'Pending') {
    html += `<button class="btn btn-success btn-sm" onclick="updateApptStatus('${id}','Approved')">✅ Approve</button> `;
    html += `<button class="btn btn-error btn-sm" onclick="updateApptStatus('${id}','Rejected')">❌ Reject</button>`;
  } else if (status === 'Approved') {
    html += `<button class="btn btn-primary btn-sm" onclick="updateApptStatus('${id}','Completed')">🏁 Complete</button>`;
  }
  return html || `<span style="color:var(--text-secondary);font-size:12px">${status}</span>`;
}

window.updateApptStatus = async (id, status) => {
  const { doc: dc, updateDoc: uDc } = window._firebase;
  try {
    await uDc(dc(window._db, 'appointments', id), { status });
    showToast(`Appointment ${status.toLowerCase()}.`, 'success');
    loadAppointments();
  } catch (e) { showToast(e.message, 'error'); }
};

// ────────── SERVICES ──────────
async function loadServices() {
  const db_ = window._db;
  const { collection: col, getDocs: gDs } = window._firebase;
  const body = document.getElementById('services-body');
  body.innerHTML = '<div class="loading"><div class="spinner"></div></div>';
  try {
    const snap = await gDs(col(db_, 'services'));
    if (snap.empty) { body.innerHTML = '<p class="loading">No services found.</p>'; return; }
    body.innerHTML = `<table>
      <thead><tr><th>Title</th><th>Description</th><th>Price (SAR)</th><th>Actions</th></tr></thead>
      <tbody>${snap.docs.map(d => {
        const s = d.data();
        return `<tr>
          <td><strong>${esc(s.title||'')}</strong></td>
          <td style="max-width:260px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${esc(s.description||'')}</td>
          <td>${(s.price||0).toFixed(0)}</td>
          <td>
            <button class="btn btn-outline btn-sm" onclick="editService('${d.id}')">✏️ Edit</button>
            <button class="btn btn-error btn-sm" onclick="confirmDelete('services','${d.id}','service ${esc(s.title||'')}')">🗑️</button>
          </td>
        </tr>`;
      }).join('')}</tbody></table>`;
  } catch (e) {
    body.innerHTML = `<p style="color:var(--error);padding:16px">${e.message}</p>`;
  }
}
window.loadServices = loadServices;

window.openServiceModal = (data = null, id = '') => {
  document.getElementById('service-modal-title').textContent = id ? 'Edit Service' : 'Add Service';
  document.getElementById('service-id').value  = id;
  document.getElementById('s-title').value = data?.title || '';
  document.getElementById('s-price').value = data?.price || '';
  document.getElementById('s-desc').value  = data?.description || '';
  document.getElementById('s-img').value   = data?.image || '';
  document.getElementById('service-modal').classList.remove('hidden');
};

window.editService = async (id) => {
  const { doc: dc, getDoc: gDc } = window._firebase;
  const snap = await gDc(dc(window._db, 'services', id));
  if (snap.exists()) openServiceModal(snap.data(), id);
};

window.saveService = async () => {
  const { collection: col, doc: dc, addDoc: aDc, updateDoc: uDc } = window._firebase;
  const id = document.getElementById('service-id').value;
  const data = {
    title:       document.getElementById('s-title').value.trim(),
    description: document.getElementById('s-desc').value.trim(),
    price:       Number(document.getElementById('s-price').value) || 0,
    image:       document.getElementById('s-img').value.trim(),
  };
  if (!data.title) { showToast('Title is required.', 'error'); return; }
  try {
    if (id) {
      await uDc(dc(window._db, 'services', id), data);
      showToast('Service updated.', 'success');
    } else {
      await aDc(col(window._db, 'services'), data);
      showToast('Service added.', 'success');
    }
    closeModal('service-modal');
    loadServices();
  } catch (e) { showToast(e.message, 'error'); }
};

// ────────── USERS ──────────
async function loadUsers() {
  const db_ = window._db;
  const { collection: col, getDocs: gDs, query: q, where: w } = window._firebase;
  const body = document.getElementById('users-body');
  body.innerHTML = '<div class="loading"><div class="spinner"></div></div>';
  try {
    const snap = await gDs(q(col(db_, 'users'), w('role', '==', 'patient')));
    if (snap.empty) { body.innerHTML = '<p class="loading">No patients found.</p>'; return; }
    body.innerHTML = `<table>
      <thead><tr><th>Name</th><th>Email</th><th>Phone</th><th>Status</th><th>Actions</th></tr></thead>
      <tbody>${snap.docs.map(d => {
        const u = d.data();
        const active = u.isActive !== false;
        return `<tr>
          <td><strong>${esc(u.name||'')}</strong></td>
          <td>${esc(u.email||'')}</td>
          <td>${esc(u.phone||'—')}</td>
          <td>${active ? '<span class="badge badge-active">Active</span>' : '<span class="badge badge-inactive">Inactive</span>'}</td>
          <td>
            <button class="btn btn-outline btn-sm" onclick="toggleUser('${d.id}',${!active})">${active ? '🚫 Deactivate' : '✅ Activate'}</button>
          </td>
        </tr>`;
      }).join('')}</tbody></table>`;
  } catch (e) {
    body.innerHTML = `<p style="color:var(--error);padding:16px">${e.message}</p>`;
  }
}
window.loadUsers = loadUsers;

window.toggleUser = async (uid, newState) => {
  const { doc: dc, updateDoc: uDc } = window._firebase;
  try {
    await uDc(dc(window._db, 'users', uid), { isActive: newState });
    showToast(`User ${newState ? 'activated' : 'deactivated'}.`, 'success');
    loadUsers();
  } catch (e) { showToast(e.message, 'error'); }
};

// ────────── REVIEWS ──────────
async function loadReviews() {
  const db_ = window._db;
  const { collection: col, getDocs: gDs } = window._firebase;
  const body = document.getElementById('reviews-body');
  body.innerHTML = '<div class="loading"><div class="spinner"></div></div>';
  try {
    const snap = await gDs(col(db_, 'reviews'));
    if (snap.empty) { body.innerHTML = '<p class="loading">No reviews found.</p>'; return; }
    const sorted = snap.docs.sort((a,b) => (b.data().createdAt?.seconds||0) - (a.data().createdAt?.seconds||0));
    body.innerHTML = `<table>
      <thead><tr><th>Patient</th><th>Dentist ID</th><th>Rating</th><th>Comment</th><th>Date</th><th>Actions</th></tr></thead>
      <tbody>${sorted.map(d => {
        const r = d.data();
        const dateStr = r.createdAt?.toDate ? r.createdAt.toDate().toLocaleDateString() : '—';
        return `<tr>
          <td>${esc(r.patientName||'')}</td>
          <td style="font-size:11px;color:var(--text-secondary)">${esc(r.dentistId||'')}</td>
          <td><span class="stars">${stars(r.rating||0)}</span> ${r.rating||0}</td>
          <td style="max-width:220px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${esc(r.comment||'')}</td>
          <td>${dateStr}</td>
          <td>
            <button class="btn btn-error btn-sm" onclick="confirmDelete('reviews','${d.id}','this review')">🗑️ Delete</button>
          </td>
        </tr>`;
      }).join('')}</tbody></table>`;
  } catch (e) {
    body.innerHTML = `<p style="color:var(--error);padding:16px">${e.message}</p>`;
  }
}
window.loadReviews = loadReviews;

// ────────── STATISTICS ──────────
async function loadStatistics() {
  const db_ = window._db;
  const { collection: col, getDocs: gDs, query: q, where: w } = window._firebase;
  try {
    const [patients, dentists, appts, reviews] = await Promise.all([
      gDs(q(col(db_, 'users'), w('role', '==', 'patient'))),
      gDs(col(db_, 'dentists')),
      gDs(col(db_, 'appointments')),
      gDs(col(db_, 'reviews')),
    ]);
    const statuses = { Pending:0, Approved:0, Completed:0, Rejected:0, Cancelled:0 };
    let totalRating = 0, ratingCount = 0;
    appts.docs.forEach(d => { const s = d.data().status; if (statuses[s] !== undefined) statuses[s]++; });
    reviews.docs.forEach(d => { totalRating += d.data().rating||0; ratingCount++; });
    const avgRating = ratingCount ? (totalRating/ratingCount).toFixed(1) : 'N/A';

    document.getElementById('stat-detailed-grid').innerHTML = `
      <div class="stat-card"><div class="stat-icon">👥</div><div class="stat-value">${patients.size}</div><div class="stat-label">Total Patients</div></div>
      <div class="stat-card"><div class="stat-icon">👨‍⚕️</div><div class="stat-value">${dentists.size}</div><div class="stat-label">Dentists</div></div>
      <div class="stat-card"><div class="stat-icon">📅</div><div class="stat-value">${appts.size}</div><div class="stat-label">Total Appointments</div></div>
      <div class="stat-card"><div class="stat-icon">✅</div><div class="stat-value">${statuses.Completed}</div><div class="stat-label">Completed</div></div>
      <div class="stat-card"><div class="stat-icon">⏳</div><div class="stat-value">${statuses.Pending}</div><div class="stat-label">Pending</div></div>
      <div class="stat-card"><div class="stat-icon">⭐</div><div class="stat-value">${avgRating}</div><div class="stat-label">Avg Rating</div></div>
    `;
    const total = appts.size || 1;
    document.getElementById('stat-breakdown-body').innerHTML = `
      <div style="padding:20px">
        ${Object.entries(statuses).map(([s, c]) => `
          <div style="margin-bottom:16px">
            <div style="display:flex;justify-content:space-between;margin-bottom:6px">
              <span>${badgeStatus(s)}</span>
              <span style="font-size:13px;color:var(--text-secondary)">${c} / ${appts.size}</span>
            </div>
            <div style="height:10px;background:var(--border);border-radius:5px;overflow:hidden">
              <div style="height:100%;width:${Math.round(c/total*100)}%;background:var(--primary);border-radius:5px;transition:width .4s"></div>
            </div>
          </div>`).join('')}
      </div>`;
  } catch (e) {
    document.getElementById('stat-detailed-grid').innerHTML = `<p style="color:var(--error)">${e.message}</p>`;
  }
}
window.loadStatistics = loadStatistics;

// ────────── DELETE ──────────
window.confirmDelete = (colName, id, label) => {
  document.getElementById('confirm-msg').textContent = `Delete ${label}? This cannot be undone.`;
  document.getElementById('confirm-ok').onclick = () => doDelete(colName, id);
  document.getElementById('confirm-modal').classList.remove('hidden');
};

window.doDelete = async (colName, id) => {
  const { doc: dc, deleteDoc: dDc } = window._firebase;
  try {
    await dDc(dc(window._db, colName, id));
    showToast('Deleted successfully.', 'success');
    closeModal('confirm-modal');
    const loaders = { dentists: loadDentists, services: loadServices, reviews: loadReviews };
    if (loaders[colName]) loaders[colName]();
  } catch (e) { showToast(e.message, 'error'); }
};

// ────────── Helpers ──────────
window.closeModal = (id) => document.getElementById(id).classList.add('hidden');

function esc(s) {
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function stars(rating) {
  const full = Math.floor(rating);
  return '★'.repeat(full) + '☆'.repeat(5 - full);
}

function badgeStatus(s) {
  const map = {
    Pending: 'badge-pending', Approved: 'badge-approved',
    Completed: 'badge-completed', Rejected: 'badge-rejected', Cancelled: 'badge-cancelled'
  };
  return `<span class="badge ${map[s]||'badge-cancelled'}">${s||'—'}</span>`;
}

window.showToast = (msg, type = 'success') => {
  const el = document.createElement('div');
  el.className = `toast-msg toast-${type}`;
  el.textContent = msg;
  document.getElementById('toast').appendChild(el);
  setTimeout(() => el.remove(), 3500);
};

// Close modals on backdrop click
document.querySelectorAll('.modal-backdrop').forEach(backdrop => {
  backdrop.addEventListener('click', e => {
    if (e.target === backdrop) backdrop.classList.add('hidden');
  });
});

// Enter key to login
document.getElementById('auth-password').addEventListener('keydown', e => {
  if (e.key === 'Enter') window.doLogin();
});
