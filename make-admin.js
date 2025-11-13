#!/usr/bin/env node

/**
 * CazLync Admin Creator
 * 
 * Usage:
 *   node make-admin.js USER_ID
 *   node make-admin.js --list (to list all users)
 * 
 * Example:
 *   node make-admin.js abc123xyz
 */

const { execSync } = require('child_process');

const args = process.argv.slice(2);

if (args.length === 0) {
  console.log('🔐 CazLync Admin Creator');
  console.log('========================\n');
  console.log('Usage:');
  console.log('  node make-admin.js USER_ID          - Make user admin');
  console.log('  node make-admin.js --list           - List all users');
  console.log('  node make-admin.js --help           - Show this help\n');
  console.log('Example:');
  console.log('  node make-admin.js abc123xyz\n');
  process.exit(0);
}

const command = args[0];

if (command === '--list') {
  console.log('📋 Listing users...\n');
  try {
    execSync('firebase firestore:get users --limit 20', { stdio: 'inherit' });
  } catch (error) {
    console.error('❌ Error listing users:', error.message);
  }
  process.exit(0);
}

if (command === '--help') {
  console.log('🔐 CazLync Admin Creator');
  console.log('========================\n');
  console.log('This tool helps you make users admin in your CazLync app.\n');
  console.log('Commands:');
  console.log('  node make-admin.js USER_ID    - Make user admin');
  console.log('  node make-admin.js --list     - List all users');
  console.log('  node make-admin.js --help     - Show this help\n');
  process.exit(0);
}

// Make user admin
const userId = command;

console.log('🔐 CazLync Admin Creator');
console.log('========================\n');
console.log(`Making user ${userId} an admin...\n`);

try {
  const cmd = `firebase firestore:update users/${userId} "{\\"isAdmin\\":true}"`;
  execSync(cmd, { stdio: 'inherit' });
  
  console.log('\n✅ Success!');
  console.log(`\nUser ${userId} is now an admin!`);
  console.log('\n📱 Next steps:');
  console.log('1. User should restart the app');
  console.log('2. Go to Profile tab');
  console.log('3. Look for "Administration" section');
  console.log('4. Tap "Admin Dashboard"\n');
} catch (error) {
  console.error('\n❌ Error:', error.message);
  console.log('\n💡 Tips:');
  console.log('- Make sure the user ID is correct');
  console.log('- Check if user exists: node make-admin.js --list');
  console.log('- User must be registered in the app first\n');
}
