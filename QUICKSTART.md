# Quick Start Guide - PulseChain Validator Setup

> **For complete beginners who want to get started FAST!**

## ⚡ 3-Step Quick Start

### Step 1: Get the Code (30 seconds)

```bash
git clone https://github.com/poseidonPLS/install_pulse_node
cd install_pulse_node
```

### Step 2: Run the Setup (30-60 minutes)

```bash
chmod +x setup_easy.sh
./setup_easy.sh
```

### Step 3: Wait for Sync (1-7 days)

Your node will automatically start syncing. Check progress:

```bash
plsmenu
```

**That's it!** The script handles everything else.

---

## 🎯 What to Expect

### During Setup

The script will ask you questions. Here are the **recommended answers for beginners**:

| Question | Recommended Answer | Why? |
|----------|-------------------|------|
| Network? | **Testnet** (for practice) | Learn without risking real PLS |
| Execution client? | **Geth** | Faster sync, less storage |
| Consensus client? | **Lighthouse** | Lower resources, popular |
| Installation path? | **/blockchain** (default) | Simple and clean |
| Setup validator? | **No** (for now) | Get node running first, add validator later |
| Setup monitoring? | **Yes** | Helpful to see what's happening |

💡 **Pro tip:** Type `?` at any question to get detailed help!

### After Setup

1. **Check containers are running:**
   ```bash
   docker ps
   ```
   You should see `execution` and `beacon` containers.

2. **View logs:**
   ```bash
   plsmenu
   ```
   Choose "Logviewer" → "AIO Logs"

3. **Check sync progress:**
   ```bash
   plsmenu
   ```
   Choose "Check Sync Status"

4. **Open monitoring dashboard:**
   ```
   http://YOUR_IP:3000
   ```
   Login: `admin` / `admin`

---

## 🆘 Something Went Wrong?

### Script says "System check failed"

**What it means:** Your system doesn't meet requirements.

**What to do:** Read the error message carefully. It will tell you exactly what's wrong:
- Not enough RAM? Upgrade or use a VPS
- Not enough disk space? Free up space or add storage
- No network? Check your internet connection

### Script stops with an error

**What to do:**
1. Read the error message
2. Check `docs/TROUBLESHOOTING.md`
3. Ask in Telegram: https://t.me/PulseDEV

### Can't see my containers

```bash
docker ps -a
```

If they're there but stopped, restart them:
```bash
plsmenu
```
Choose "Clients Menu" → "Start all Clients"

---

## 📖 Want More Details?

- **Complete guide:** See `README_BEGINNER.md`
- **Troubleshooting:** See `docs/TROUBLESHOOTING.md`
- **Original docs:** See `README.md`

---

## 🎓 Learning Path

### Phase 1: Get Node Running (You are here!)
- ✅ Run `setup_easy.sh`
- ✅ Wait for sync to complete
- ✅ Monitor with Grafana

### Phase 2: Add Validator (After sync completes)
- Run `./setup_validator.sh`
- Generate validator keys
- Deposit 32M PLS (testnet or mainnet)

### Phase 3: Maintain & Monitor
- Check logs regularly
- Keep system updated
- Monitor validator performance

---

**Ready?** Just run:
```bash
./setup_easy.sh
```

**Questions?** Join us: https://t.me/PulseDEV

---

*Original setup by tdslaine • Enhanced by poseidonPLS*
