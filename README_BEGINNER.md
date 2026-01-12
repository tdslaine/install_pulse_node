# PulseChain Validator Setup - Complete Beginner's Guide

> **Original setup by:** [tdslaine (Peter L Dipslayer)](https://github.com/tdslaine/install_pulse_node)  
> **Enhanced for beginners by:** poseidonPLS

---

## 🎯 Quick Start (For Complete Beginners)

**New to validators? Start here!**

```bash
# 1. Download the setup
git clone https://github.com/poseidonPLS/install_pulse_node
cd install_pulse_node

# 2. Run the beginner-friendly setup
chmod +x setup_easy.sh
./setup_easy.sh
```

That's it! The script will guide you through everything step-by-step.

---

## 📋 What You Need Before Starting

### Hardware Requirements

| Component | Minimum | Recommended | Why? |
|-----------|---------|-------------|------|
| **RAM** | 16GB | 32GB | More RAM = faster sync & better performance |
| **Storage** | 1TB SSD | 2TB+ SSD | Blockchain data grows over time. **Must be SSD!** |
| **CPU** | 4 cores | 8+ cores | More cores = faster processing |
| **Internet** | 10 Mbps | 25+ Mbps | Stable connection required 24/7 |

⚠️ **HDD (Hard Disk Drive) will NOT work!** You must use an SSD.

### Software Requirements

- **Operating System:** Ubuntu 20.04 LTS or newer (22.04 LTS recommended)
- **For Mainnet Validator:** 32,000,000 PLS tokens

### Time Requirements

- **Installation:** 30-60 minutes
- **Blockchain Sync:** 1-7 days (varies by client choice)

---

## 🚀 Installation Options

### Option 1: Beginner-Friendly (Recommended for New Users)

This includes pre-flight checks, helpful explanations, and safety warnings:

```bash
./setup_easy.sh
```

**Features:**
- ✅ Checks your system BEFORE starting
- ✅ Explains every choice in plain English
- ✅ Catches common mistakes before they happen
- ✅ Shows progress and estimated time
- ✅ Includes safety warnings at critical steps

### Option 2: Original Setup (For Experienced Users)

If you've done this before and want the original experience:

```bash
./setup_pulse_node.sh
```

### Option 3: Just Check System Requirements

Want to see if your system is ready without installing anything?

```bash
./setup_easy.sh --check-only
```

---

## 📖 Step-by-Step Walkthrough

### Step 1: System Check (Automatic)

The script will check:
- ✓ Operating system compatibility
- ✓ CPU cores (need at least 4)
- ✓ RAM (need at least 16GB)
- ✓ Disk space (need at least 1TB)
- ✓ Network connectivity
- ✓ Port availability

**If anything fails:** The script will tell you exactly what's wrong and how to fix it.

### Step 2: Choose Network

**Mainnet** = Real PulseChain (real PLS, real rewards)  
**Testnet** = Practice network (free test PLS, no real value)

💡 **Beginner tip:** Start with Testnet to learn without risk!

### Step 3: Choose Execution Client

**Geth** (Recommended for most users)
- ✅ Faster sync (days instead of weeks)
- ✅ Less disk space
- ✅ Proven reliability

**Erigon** (For advanced users)
- ✅ Full historical data
- ⚠️ Much slower sync
- ⚠️ Needs 3TB+ storage

💡 **Beginner tip:** Choose Geth unless you specifically need historical blockchain data.

### Step 4: Choose Consensus Client

**Lighthouse** or **Prysm** - Both are excellent!

💡 **Beginner tip:** Lighthouse uses slightly less resources. Either choice is fine.

### Step 5: Choose Installation Path

Default: `/blockchain`

💡 **Beginner tip:** Use the default unless you have a specific reason to change it. Make sure it's on your SSD!

### Step 6: Firewall Setup

The script will configure your firewall automatically to protect your validator.

**You'll be asked:**

**1. Allow SSH access?**
- **What is SSH?** Secure Shell - lets you connect to your server remotely via terminal
- **Say YES if:** You're running on a VPS or remote server (you need this to connect!)
- **Say NO if:** Running on a local machine you can access directly
- **Security note:** SSH will only be allowed from your local network for safety

**2. Allow RPC access?**
- **What is RPC?** Remote Procedure Call - lets other apps query your node's blockchain data
- **Say NO if:** Just running a validator (most people - this is the safe default)
- **Say YES if:** You need to connect wallets/dApps to your node, or you're a developer
- **Security note:** RPC will only be accessible from localhost and your local network, never from the internet

### Step 7: Validator Setup (Optional)

**Only do this if you want to run a validator!**

#### 🔐 CRITICAL: Key Generation Security

**Your validator keys = 32,000,000 PLS. Choose wisely!**

The setup will ask how you want to generate keys:

**Option 1: Generate New Keys**
- Creates brand new validator keys
- Gives you a 24-word seed phrase
- ⚠️ **For MAINNET:** Should be done OFFLINE! (see below)
- ✅ **For TESTNET:** Online is acceptable for practice

**Option 2: Import from Offline Generation** ⭐ **RECOMMENDED for MAINNET**
- You generated keys on an offline machine
- Now importing the keystore files
- Seed phrase never touched the internet
- Maximum security for real PLS

**Option 3: Restore from Seed Phrase**
- You already have a seed phrase
- Recreating keys from it
- Use for recovery only

#### 🛡️ For MAINNET: Use Offline Key Generation!

**Why?** Your seed phrase = Full control of 32M PLS
- Malware could steal it if generated online
- Keyloggers could record it
- Network could leak it

**How?** Use a separate, offline machine:
```bash
# On an offline machine (USB live boot recommended):
./setup_offline_keygen.sh
```

**Full guide:** See `docs/KEYGEN_SECURITY.md` for step-by-step instructions

#### Enhanced Safety Features

The setup now includes:
- ✅ **Automatic online detection** - Warns if generating keys while connected
- ✅ **Network disconnect option** - Helps you go offline safely
- ✅ **Mainnet warnings** - Extra warnings for real PLS
- ✅ **Seed phrase backup verification** - Ensures you backed it up properly

#### What You'll Need to Provide

1. **Withdrawal address** - Where rewards go (CANNOT be changed later!)
2. **Fee recipient** - Where transaction fees go (can use same as withdrawal)
3. **Graffiti** - Optional custom message in your blocks

⚠️ **CRITICAL:** Write down your seed phrase on paper and store it safely!

---

## 🔐 Security Best Practices

### For Key Generation

**MAINNET (Real PLS):**
1. ✅ **Use offline key generation** (see `docs/KEYGEN_SECURITY.md`)
2. ✅ **Use USB live boot** (Ubuntu) for air-gapped environment
3. ✅ **Never connect that machine to internet again**
4. ✅ **Only transfer keystore files** (not seed phrase!)

**TESTNET (Practice):**
- Online generation is acceptable
- Good opportunity to learn the process
- No real funds at risk

### For Your Seed Phrase

1. ✅ **Write on paper** (not on computer!)
2. ✅ **Use permanent ink** (won't fade)
3. ✅ **Store in fireproof safe** or safety deposit box
4. ✅ **Verify you can read it** before storing
5. ❌ **Never take a photo**
6. ❌ **Never type it on any computer** (except offline keygen)
7. ❌ **Never share with anyone** (not even "support")
8. ❌ **Never store digitally** (no cloud, no password manager)

### For Your Withdrawal Address

1. ✅ **Use a hardware wallet** (Ledger, Trezor)
2. ✅ **Copy address from block explorer** (ensures correct checksum)
3. ✅ **Triple-check it's correct** (cannot be changed later!)
4. ❌ **Never use an exchange address**
5. ❌ **Never share your private keys**

### For Your Validator Keys

1. ✅ **Write seed phrase on paper** (not on computer!)
2. ✅ **Store in safe place** (fireproof safe, safety deposit box)
3. ✅ **Never share with anyone**
4. ❌ **Never run same keys on multiple machines** (will get slashed!)
5. ❌ **Never store seed phrase digitally** (no photos, no cloud storage!)

---

## 📊 After Installation

### Check if Everything is Running

```bash
docker ps
```

You should see 2-3 containers:
- `execution` (Geth or Erigon)
- `beacon` (Lighthouse or Prysm)
- `validator` (if you set one up)

### View Logs

**Easy way (GUI):**
```bash
plsmenu
```
Then choose "Logviewer"

**Command line way:**
```bash
docker logs -f --tail=50 execution
docker logs -f --tail=50 beacon
docker logs -f --tail=50 validator
```

### Check Sync Status

```bash
plsmenu
```
Choose "Check Sync Status"

**What to expect:**
- Execution client: Will show sync percentage
- Beacon client: Will show slot numbers
- **Full sync can take 1-7 days!**

### Monitor Your Validator

Open Grafana dashboard:
```
http://YOUR_SERVER_IP:3000
```

Default login:
- Username: `admin`
- Password: `admin`

---

## ❓ Common Questions (FAQ)

### How long does sync take?

- **Geth:** 1-3 days typically
- **Erigon:** 1-2 weeks typically
- Depends on your internet speed and hardware

### Can I close my terminal during sync?

Yes! The Docker containers run in the background. You can safely disconnect.

### How do I know when sync is complete?

Check the logs or Grafana dashboard. When execution and beacon are both synced, you're ready!

### What if something goes wrong?

1. Check `docs/TROUBLESHOOTING.md`
2. Run `plsmenu` and check logs
3. Ask in PulseDEV Telegram: https://t.me/PulseDEV

### Can I run this on a VPS?

Yes! Many people use VPS providers like:
- Contabo
- Hetzner
- OVH
- DigitalOcean

Make sure it meets the hardware requirements!

### How much does it cost to run?

**Hardware costs:**
- VPS: $20-50/month typically
- Home server: $500-1500 one-time

**Staking requirement:**
- Mainnet: 32,000,000 PLS per validator

### When do I get rewards?

After your validator is:
1. Fully synced
2. Activated on the network (after depositing 32M PLS)
3. Performing duties correctly

Rewards accumulate automatically!

---

## 🆘 Troubleshooting

### "Insufficient disk space" error

**Solution:** You need at least 1TB free. Either:
- Free up space
- Add an external SSD
- Use a different installation path with more space

### "Port already in use" error

**Solution:** Another service is using the required port.

Find what's using it:
```bash
sudo netstat -tulnp | grep :30303
```

Either stop that service or choose a different port.

### "Cannot connect to Docker daemon" error

**Solution:** Docker service isn't running.

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### Sync is very slow

**Possible causes:**
1. Slow internet connection
2. Using HDD instead of SSD
3. Insufficient RAM
4. Network congestion

**Solutions:**
- Upgrade to SSD if using HDD
- Check internet speed
- Add more RAM if possible

### More help needed?

Check `docs/TROUBLESHOOTING.md` for detailed solutions!

---

## 📚 Additional Resources

- **Official PulseChain:** https://pulsechain.com/
- **Validator Launchpad:** https://launchpad.pulsechain.com/
- **Block Explorer:** https://scan.pulsechain.com/
- **PulseDEV Telegram:** https://t.me/PulseDEV
- **Original Repository:** https://github.com/tdslaine/install_pulse_node

---

## 🙏 Credits

**Original Setup Script:**
- Created by: **tdslaine (Peter L Dipslayer)**
- Telegram: @dipslayer369
- Twitter: @dipslayer

**Special Thanks:**
- @rainbowtopgun - Invaluable feedback and support
- raskitoma - Forking the Yoldark_ETH_staking_dashboard
- PulseDEV Telegram community
- All contributors who provided feedback

**Beginner-Friendly Enhancements:**
- Enhanced by: **poseidonPLS**
- Added: Pre-flight checks, validation, help system, error prevention

---

## 📄 License

This project maintains the same license as the original repository.

---

**Ready to begin?** Run `./setup_easy.sh` and let's get started! 🚀
