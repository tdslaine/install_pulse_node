# Secure Key Generation Guide

> **Your validator keys = 32,000,000 PLS. Protect them!**

## 🔐 The Simple Truth

**If someone gets your seed phrase, they can steal ALL your PLS.**  
**If you lose your seed phrase, your PLS is gone forever.**  
**There is NO recovery. NO support can help you.**

This is why key generation security matters.

---

## 🎯 Quick Decision Guide

### Are you setting up for MAINNET (real PLS)?
→ **Use offline key generation** (see below)

### Are you setting up for TESTNET (practice)?
→ Online generation is fine (no real funds at risk)

---

## 🛡️ Recommended: Offline Key Generation

### Why Offline?

When you generate keys online:
- ❌ Malware could steal your seed phrase
- ❌ Keyloggers could record it
- ❌ Network traffic could leak it
- ❌ Your computer might be compromised

When you generate keys offline:
- ✅ Seed phrase never touches the internet
- ✅ No network = No remote attacks
- ✅ Air-gapped = Maximum security
- ✅ Peace of mind with 32M PLS

### The Offline Method (Step-by-Step)

**What you need:**
- A spare computer or laptop (doesn't need to be powerful)
- A USB drive (8GB+)
- Ubuntu live USB (we'll create this)

**Steps:**

#### 1. Create Ubuntu Live USB (on any computer)

```bash
# Download Ubuntu 22.04 LTS
# Visit: https://ubuntu.com/download/desktop

# Use Rufus (Windows) or Etcher (Mac/Linux) to create bootable USB
# This will be your offline key generation environment
```

#### 2. Prepare the Offline Machine

```bash
# Boot from Ubuntu USB (don't install, choose "Try Ubuntu")
# Once booted, DISCONNECT from internet:
  - Unplug ethernet cable
  - Turn off WiFi
  - Verify: ping 8.8.8.8 (should fail)
```

#### 3. Get the Setup Script

```bash
# Before going offline, download the setup:
git clone https://github.com/poseidonPLS/install_pulse_node
cd install_pulse_node

# NOW disconnect from internet (see step 2)
```

#### 4. Run Offline Key Generator

```bash
chmod +x setup_offline_keygen.sh
./setup_offline_keygen.sh
```

#### 5. Generate Your Keys

The script will:
- ✅ Verify you're offline
- ✅ Guide you through key generation
- ✅ Show you your 24-word seed phrase
- ✅ Create keystore files

**CRITICAL: Write down your seed phrase on paper!**

#### 6. Save Keystores to USB

```bash
# The keystores will be in: validator_keys/
# Copy ONLY the keystore files to USB (NOT the seed phrase!)

cp -r validator_keys /media/usb/
```

#### 7. Secure Your Seed Phrase

- ✅ Write it on paper (permanent ink)
- ✅ Store in fireproof safe
- ✅ Consider safety deposit box
- ✅ NEVER type it on any computer again
- ✅ NEVER take a photo
- ✅ NEVER store digitally

#### 8. Import Keys on Your Validator

```bash
# On your validator machine:
./setup_validator.sh

# Choose option: "Import keys from offline generation"
# Point to the keystores from your USB
```

#### 9. Destroy the Offline Environment

```bash
# Shut down the Ubuntu live system
# The USB will be clean on next boot
# Your seed phrase never touched a hard drive!
```

---

## ⚡ Alternative: Online Generation (Testnet Only!)

If you're just practicing on testnet, online generation is acceptable:

```bash
./setup_validator.sh

# Choose: "Generate new keys"
# Follow the prompts
# Still write down your seed phrase!
```

**The enhanced setup will:**
- ⚠️ Warn you if online
- ⚠️ Show security risks
- ⚠️ Give you option to disconnect first
- ⚠️ Require confirmation for mainnet

---

## 📝 Seed Phrase Backup Checklist

Before you continue, verify:

- [ ] I wrote down all 24 words on paper
- [ ] I numbered them 1-24 in order
- [ ] I double-checked the spelling
- [ ] I can read my handwriting clearly
- [ ] I stored the paper in a safe place
- [ ] I did NOT take a photo
- [ ] I did NOT save it on computer
- [ ] I did NOT email it to myself
- [ ] I did NOT store it in cloud
- [ ] I understand this is the ONLY backup

---

## 🆘 Common Questions

### Can I just write it in a text file?
**NO!** Text files can be:
- Stolen by malware
- Backed up to cloud automatically
- Recovered from deleted files
- Accessed by anyone who hacks your computer

### Can I take a photo for backup?
**NO!** Photos:
- Sync to cloud (iCloud, Google Photos)
- Can be recovered from phone
- Might be backed up automatically
- Could be stolen if phone is hacked

### What if I lose the paper?
Your PLS is gone forever. There is no recovery.  
This is why you should:
- Use quality paper that won't fade
- Store in fireproof safe
- Consider multiple copies in different locations (advanced)

### Can I split the seed phrase?
Advanced users can split it (e.g., words 1-12 in one location, 13-24 in another).  
But for beginners: Keep it together in one safe place.

### What if someone finds my seed phrase?
They can steal all your PLS immediately.  
Treat it like 32,000,000 PLS in cash.

---

## 🔒 Security Best Practices

### DO:
- ✅ Use offline key generation for mainnet
- ✅ Write seed phrase on paper
- ✅ Store in fireproof safe
- ✅ Use hardware wallet for withdrawal address
- ✅ Test the process on testnet first
- ✅ Verify your backups

### DON'T:
- ❌ Generate mainnet keys online
- ❌ Store seed phrase digitally
- ❌ Share seed phrase with anyone
- ❌ Take photos of seed phrase
- ❌ Email or message seed phrase
- ❌ Store in password manager
- ❌ Trust anyone who asks for it

---

## 🎓 Learning Path

### Phase 1: Practice (Testnet)
1. Generate testnet keys online (acceptable for practice)
2. Learn the process
3. Practice backup and recovery
4. Get comfortable with the tools

### Phase 2: Real Deal (Mainnet)
1. Get offline machine ready
2. Use offline key generation
3. Secure seed phrase properly
4. Import keys to validator
5. Deposit real PLS

---

## 📚 Additional Resources

- **Offline Keygen Script:** `./setup_offline_keygen.sh`
- **Original Documentation:** `README.md`
- **Troubleshooting:** `docs/TROUBLESHOOTING.md`
- **PulseDEV Telegram:** https://t.me/PulseDEV

---

**Remember:** Your validator keys are worth 32,000,000 PLS.  
Take security seriously. Use offline generation for mainnet.

---

*Original setup by tdslaine • Enhanced security by poseidonPLS*
