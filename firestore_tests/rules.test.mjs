import { initializeTestEnvironment, assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, setDoc, updateDoc, getDoc, getDocs, collection, query, where, writeBatch, Timestamp } from 'firebase/firestore';
import { readFileSync } from 'node:fs';
import test, { before, beforeEach, after } from 'node:test';

let env;
before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-dental',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});
after(async () => env.cleanup());

const day = new Date(2026, 11, 15); // local midnight
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users/admin'), { uid: 'admin', role: 'admin', isActive: true });
    await setDoc(doc(db, 'users/alice'), { uid: 'alice', role: 'patient', isActive: true, name: 'Alice' });
    await setDoc(doc(db, 'users/bob'), { uid: 'bob', role: 'patient', isActive: true, name: 'Bob' });
    await setDoc(doc(db, 'users/banned'), { uid: 'banned', role: 'patient', isActive: false });
    await setDoc(doc(db, 'dentists/d1'), { name: 'Dr', averageRating: 0, totalReviews: 0, ratingSum: 0 });
    await setDoc(doc(db, 'dentists/legacy'), { name: 'Old', averageRating: 4.5, totalReviews: 2 });
    await setDoc(doc(db, 'appointments/done1'), { patientId: 'alice', dentistId: 'd1', status: 'Completed', time: '09:00', date: Timestamp.fromDate(day) });
    await setDoc(doc(db, 'appointments/done2'), { patientId: 'alice', dentistId: 'legacy', status: 'Completed', time: '09:00', date: Timestamp.fromDate(day) });
    await setDoc(doc(db, 'appointments/legacyAppt'), { patientId: 'alice', dentistId: 'd1', status: 'Pending', time: '11:00', date: Timestamp.fromDate(day) });
    await setDoc(doc(db, 'notifications/n1'), { receiverId: 'alice', isRead: false, title: 't' });
  });
});

const as = (uid) => env.authenticatedContext(uid).firestore();

function book(db, { uid = 'alice', apptId = 'a1', time = '10:00', date = day, dayKey = '2026-12-15', status = 'Pending', slot = true, slotIdOverride } = {}) {
  const slotId = slotIdOverride ?? `d1_${dayKey}_${time}`;
  const b = writeBatch(db);
  b.set(doc(db, 'appointments', apptId), {
    patientId: uid, patientName: 'X', dentistId: 'd1', dentistName: 'Dr',
    date: Timestamp.fromDate(date), time, status, isPaid: true, createdAt: Timestamp.now(), slotId,
  });
  if (slot) b.set(doc(db, 'booked_slots', slotId), { dentistId: 'd1', date: dayKey, time, appointmentId: apptId });
  return b.commit();
}

// ── Users ──
test('patient cannot self-register as admin', async () => {
  await assertFails(setDoc(doc(as('eve'), 'users/eve'), { uid: 'eve', role: 'admin', isActive: true }));
  await assertSucceeds(setDoc(doc(as('eve'), 'users/eve'), { uid: 'eve', role: 'patient', isActive: true }));
});
test('patient cannot promote or re-enable themselves, but can edit profile', async () => {
  await assertFails(updateDoc(doc(as('alice'), 'users/alice'), { role: 'admin' }));
  await assertFails(updateDoc(doc(as('banned'), 'users/banned'), { isActive: true }));
  await assertSucceeds(updateDoc(doc(as('alice'), 'users/alice'), { name: 'Alice B', fcmToken: 'tok' }));
  await assertFails(getDoc(doc(as('bob'), 'users/alice')));
});
test('admin can change roles', async () => {
  await assertSucceeds(updateDoc(doc(as('admin'), 'users/bob'), { isActive: false }));
});

// ── Booking ──
test('patient books appointment + slot together, others see slot taken', async () => {
  await assertSucceeds(book(as('alice')));
  const snap = await assertSucceeds(getDocs(query(collection(as('bob'), 'booked_slots'), where('dentistId', '==', 'd1'), where('date', '==', '2026-12-15'))));
  if (snap.size !== 1 || snap.docs[0].data().time !== '10:00') throw new Error('slot not visible');
  await assertFails(getDoc(doc(as('bob'), 'appointments/a1')));
});
test('local midnight in UTC+3 (stored as previous UTC day) is accepted', async () => {
  await assertSucceeds(book(as('alice'), { date: new Date(Date.UTC(2026, 11, 14, 21)) }));
});
test('second patient cannot take the same slot', async () => {
  await book(as('alice'));
  await assertFails(book(as('bob'), { uid: 'bob', apptId: 'b1' }));
});
test('appointment without a slot, wrong status, inactive user, or other patient id is rejected', async () => {
  await assertFails(book(as('alice'), { slot: false }));
  await assertFails(book(as('alice'), { status: 'Approved' }));
  await assertFails(book(as('banned'), { uid: 'banned' }));
  await assertFails(book(as('alice'), { uid: 'bob' }));
});
test('slot day must match appointment date and id must match fields', async () => {
  await assertFails(book(as('alice'), { date: new Date(2026, 11, 20) }));
  await assertFails(book(as('alice'), { slotIdOverride: 'd1_2026-12-15_23:00' }));
});
test('patient can cancel (and free slot) but not approve or edit other fields', async () => {
  await book(as('alice'));
  await assertFails(updateDoc(doc(as('alice'), 'appointments/a1'), { status: 'Approved' }));
  await assertFails(updateDoc(doc(as('alice'), 'appointments/a1'), { isPaid: false }));
  await assertFails(updateDoc(doc(as('bob'), 'appointments/a1'), { status: 'Cancelled' }));
  const db = as('alice');
  const b = writeBatch(db);
  b.update(doc(db, 'appointments/a1'), { status: 'Cancelled' });
  b.delete(doc(db, 'booked_slots/d1_2026-12-15_10:00'));
  await assertSucceeds(b.commit());
  await assertSucceeds(book(as('bob'), { uid: 'bob', apptId: 'b1' }));
});
test('patient cannot free a slot without cancelling, nor free someone else\'s', async () => {
  await book(as('alice'));
  const { deleteDoc } = await import('firebase/firestore');
  await assertFails(deleteDoc(doc(as('alice'), 'booked_slots/d1_2026-12-15_10:00')));
  await assertFails(deleteDoc(doc(as('bob'), 'booked_slots/d1_2026-12-15_10:00')));
});
test('legacy appointment (no slotId) can still be cancelled', async () => {
  await assertSucceeds(updateDoc(doc(as('alice'), 'appointments/legacyAppt'), { status: 'Cancelled' }));
});
test('admin rejects and frees slot', async () => {
  await book(as('alice'));
  const db = as('admin');
  const b = writeBatch(db);
  b.update(doc(db, 'appointments/a1'), { status: 'Rejected' });
  b.delete(doc(db, 'booked_slots/d1_2026-12-15_10:00'));
  await assertSucceeds(b.commit());
});

// ── Reviews ──
function review(db, { uid = 'alice', dentist = 'd1', appt = 'done1', rating = 4, newSum, newTotal, newAvg, updateDentist = true, id } = {}) {
  const b = writeBatch(db);
  b.set(doc(db, 'reviews', id ?? `${uid}_${dentist}`), {
    patientId: uid, patientName: 'A', patientImage: '', dentistId: dentist, appointmentId: appt,
    rating, comment: 'Great dentist!', createdAt: Timestamp.now(),
  });
  if (updateDentist) b.update(doc(db, 'dentists', dentist), { ratingSum: newSum, totalReviews: newTotal, averageRating: newAvg });
  return b.commit();
}
test('valid review updates dentist rating consistently', async () => {
  await assertSucceeds(review(as('alice'), { rating: 4, newSum: 4, newTotal: 1, newAvg: 4 }));
});
test('legacy dentist without ratingSum: derived sum accepted', async () => {
  // 4.5 * 2 + 3 = 12 → avg 4
  await assertSucceeds(review(as('alice'), { dentist: 'legacy', appt: 'done2', rating: 3, newSum: 12, newTotal: 3, newAvg: 4 }));
});
test('fractional averages compare equal to client-side division', async () => {
  // 4 + 3 + 4 = 11 / 3
  await env.withSecurityRulesDisabled(async (ctx) => updateDoc(doc(ctx.firestore(), 'dentists/d1'), { ratingSum: 7, totalReviews: 2, averageRating: 3.5 }));
  await assertSucceeds(review(as('alice'), { rating: 4, newSum: 11, newTotal: 3, newAvg: 11 / 3 }));
});
test('inflated rating, missing dentist update, bad rating, no completed visit, duplicate → rejected', async () => {
  await assertFails(review(as('alice'), { rating: 4, newSum: 50, newTotal: 1, newAvg: 50 }));
  await assertFails(review(as('alice'), { rating: 4, newSum: 4, newTotal: 1, newAvg: 5 }));
  await assertFails(review(as('alice'), { updateDentist: false }));
  await assertFails(review(as('alice'), { rating: 6, newSum: 6, newTotal: 1, newAvg: 6 }));
  await assertFails(review(as('bob'), { uid: 'bob', rating: 4, newSum: 4, newTotal: 1, newAvg: 4 }));
  await assertFails(review(as('alice'), { id: 'random', rating: 4, newSum: 4, newTotal: 1, newAvg: 4 }));
  await review(as('alice'), { rating: 4, newSum: 4, newTotal: 1, newAvg: 4 });
  await assertFails(review(as('alice'), { rating: 5, newSum: 9, newTotal: 2, newAvg: 4.5 }));
});
test('patient cannot edit dentist profile fields', async () => {
  await assertFails(updateDoc(doc(as('alice'), 'dentists/d1'), { name: 'Hacked' }));
  await assertFails(updateDoc(doc(as('alice'), 'dentists/d1'), { averageRating: 5 }));
});

// ── Notifications ──
test('user can only mark own notification read', async () => {
  await assertSucceeds(updateDoc(doc(as('alice'), 'notifications/n1'), { isRead: true }));
  await assertFails(updateDoc(doc(as('alice'), 'notifications/n1'), { title: 'x' }));
  await assertFails(updateDoc(doc(as('bob'), 'notifications/n1'), { isRead: true }));
});

test('second patient can book a different time', async () => {
  await book(as('alice'));
  await assertSucceeds(book(as('bob'), { uid: 'bob', apptId: 'b1', time: '10:30' }));
});
test('integer and double sums both accepted', async () => {
  await env.withSecurityRulesDisabled(async (ctx) => updateDoc(doc(ctx.firestore(), 'dentists/d1'), { ratingSum: 7.0, totalReviews: 2, averageRating: 3.5 }));
  await assertSucceeds(review(as('alice'), { rating: 5, newSum: 12, newTotal: 3, newAvg: 4 }));
});
