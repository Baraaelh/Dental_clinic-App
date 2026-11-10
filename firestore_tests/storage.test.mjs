import { initializeTestEnvironment, assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, setDoc } from 'firebase/firestore';
import { ref, uploadBytes, deleteObject, getBytes } from 'firebase/storage';
import { readFileSync } from 'node:fs';
import test, { before, after, beforeEach } from 'node:test';

let env;
before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-dental',
    storage: { rules: readFileSync('../storage.rules', 'utf8') },
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});
after(async () => env.cleanup());
beforeEach(async () => {
  await env.clearStorage();
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'users/admin'), { uid: 'admin', role: 'admin', isActive: true });
    await setDoc(doc(ctx.firestore(), 'users/alice'), { uid: 'alice', role: 'patient', isActive: true });
  });
});

const jpg = new Uint8Array([0xff, 0xd8, 0xff, 0xe0, 1, 2, 3]);
const img = { contentType: 'image/jpeg' };
const st = (uid) => env.authenticatedContext(uid).storage();

test('patient uploads own profile photo, not someone else\'s', async () => {
  await assertSucceeds(uploadBytes(ref(st('alice'), 'profile_images/alice_1700000000000.jpg'), jpg, img));
  await assertFails(uploadBytes(ref(st('alice'), 'profile_images/bob_1700000000000.jpg'), jpg, img));
  await assertFails(uploadBytes(ref(st('alice'), 'profile_images/alice_1.jpg.html'), jpg, img));
});
test('non-images and files over 5MB are rejected', async () => {
  await assertFails(uploadBytes(ref(st('alice'), 'profile_images/alice_1.jpg'), jpg, { contentType: 'text/html' }));
  await assertFails(uploadBytes(ref(st('alice'), 'profile_images/alice_2.jpg'), new Uint8Array(5 * 1024 * 1024 + 1), img));
});
test('patient deletes only own photos', async () => {
  await uploadBytes(ref(st('alice'), 'profile_images/alice_1.jpg'), jpg, img);
  await assertFails(deleteObject(ref(st('bob'), 'profile_images/alice_1.jpg')));
  await assertSucceeds(deleteObject(ref(st('alice'), 'profile_images/alice_1.jpg')));
});
test('only admins upload dentist and service photos', async () => {
  await assertFails(uploadBytes(ref(st('alice'), 'dentist_images/1_1.jpg'), jpg, img));
  await assertSucceeds(uploadBytes(ref(st('admin'), 'dentist_images/1_1.jpg'), jpg, img));
  await assertSucceeds(uploadBytes(ref(st('admin'), 'service_images/1_1.jpg'), jpg, img));
  await assertFails(deleteObject(ref(st('alice'), 'dentist_images/1_1.jpg')));
});
test('signed-out users cannot read; unknown paths are closed', async () => {
  await uploadBytes(ref(st('admin'), 'dentist_images/1_1.jpg'), jpg, img);
  await assertFails(getBytes(ref(env.unauthenticatedContext().storage(), 'dentist_images/1_1.jpg')));
  await assertSucceeds(getBytes(ref(st('alice'), 'dentist_images/1_1.jpg')));
  await assertFails(uploadBytes(ref(st('admin'), 'other/x.jpg'), jpg, img));
});
