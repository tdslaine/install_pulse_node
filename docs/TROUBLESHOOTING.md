# Troubleshooting Guide

> **Common problems and how to fix them**

## 🔍 Pre-Installation Issues

### "Insufficient RAM" Error

**Problem:** System has less than 16GB RAM

**Solutions:**
1. **Upgrade RAM** (if physical server)
2. **Use a VPS** with more RAM (recommended: 32GB)
3. **Add swap space** (temporary workaround, not ideal):
   ```bash
   sudo fallocate -l 16G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

### "Insufficient disk space" Error

**Problem:** Less than 1TB available

**Solutions:**
1. **Free up space:**
   ```bash
   # Find large files
   sudo du -h / | sort -rh | head -20
   
   # Clean package cache
   sudo apt clean
   sudo apt autoremove
   ```

2. **Add external drive:**
   ```bash
   # Mount drive
   sudo mkdir /mnt/blockchain
   sudo mount /dev/sdX /mnt/blockchain
   
   # Use during setup
   # When asked for path, enter: /mnt/blockchain
   ```

3. **Use VPS with more storage**

### "Port already in use" Error

**Problem:** Required ports (30303, 9000, etc.) are occupied

**Find what's using the port:**
```bash
sudo netstat -tulnp | grep :30303
```

**Solutions:**
1. **Stop the conflicting service:**
   ```bash
   sudo systemctl stop <service-name>
   ```

2. **Remove old Docker containers:**
   ```bash
   docker stop $(docker ps -aq)
   docker rm $(docker ps -aq)
   ```

### "No network connectivity" Error

**Problem:** Cannot reach internet

**Check connection:**
```bash
ping -c 3 8.8.8.8
```

**Solutions:**
1. **Check physical connection** (cable, WiFi)
2. **Restart network:**
   ```bash
   sudo systemctl restart NetworkManager
   ```
3. **Check firewall:**
   ```bash
   sudo ufw status
   ```

---

## 🐳 Docker Issues

### "Cannot connect to Docker daemon"

**Problem:** Docker isn't running

**Solution:**
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### "Permission denied" when running Docker

**Problem:** User not in docker group

**Solution:**
```bash
sudo usermod -aG docker $USER
# Log out and log back in
```

### Docker containers keep restarting

**Check logs:**
```bash
docker logs execution
docker logs beacon
```

**Common causes:**
1. **Insufficient resources** - Check RAM/CPU usage
2. **Corrupted data** - May need to resync
3. **Wrong configuration** - Check start scripts

---

## 🔄 Sync Issues

### Sync is very slow

**Check current status:**
```bash
plsmenu
# Choose "Check Sync Status"
```

**Common causes:**

1. **Slow internet:**
   ```bash
   # Test speed
   speedtest-cli
   ```

2. **Using HDD instead of SSD:**
   ```bash
   # Check disk type
   lsblk -d -o name,rota
   # rota=1 means HDD, rota=0 means SSD
   ```

3. **Insufficient resources:**
   ```bash
   # Check resource usage
   htop
   ```

**Solutions:**
- Upgrade to SSD (critical!)
- Increase RAM if possible
- Check internet speed (need 10+ Mbps)

### Sync appears stuck

**Check if it's actually stuck:**
```bash
# Watch logs for activity
docker logs -f --tail=100 execution
```

**If truly stuck:**
1. **Restart clients:**
   ```bash
   plsmenu
   # Clients Menu → Restart all Clients
   ```

2. **Check peers:**
   ```bash
   # Should have 10+ peers
   docker logs execution | grep -i peer
   ```

3. **Last resort - resync:**
   ```bash
   # Stop containers
   plsmenu # Stop all clients
   
   # Remove data (CAREFUL!)
   sudo rm -rf /blockchain/execution/*
   sudo rm -rf /blockchain/consensus/*
   
   # Restart
   plsmenu # Start all clients
   ```

---

## 🔑 Validator Issues

### "Invalid withdrawal address" Error

**Problem:** Address format is wrong

**Solution:**
1. Get address from block explorer (ensures checksum)
2. Must start with `0x`
3. Must be exactly 42 characters
4. Must have mixed upper/lowercase

**Example valid address:**
```
0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B
```

### Cannot import validator keys

**Check permissions:**
```bash
ls -la /blockchain/validator_keys/
```

**Fix permissions:**
```bash
sudo chmod -R 770 /blockchain/validator_keys
sudo chown -R $USER:pls-validator /blockchain/validator_keys
```

### Validator not attesting

**Check validator is running:**
```bash
docker ps | grep validator
```

**Check logs:**
```bash
docker logs -f validator
```

**Common causes:**
1. **Beacon not synced** - Wait for full sync
2. **Keys not imported** - Reimport keys
3. **Wrong network** - Check mainnet vs testnet

---

## 📊 Monitoring Issues

### Cannot access Grafana (port 3000)

**Check if Grafana is running:**
```bash
docker ps | grep grafana
```

**Check firewall:**
```bash
sudo ufw status
```

**Allow access:**
```bash
# For local network
sudo ufw allow from 192.168.0.0/24 to any port 3000

# Reload firewall
sudo ufw reload
```

### Grafana shows no data

**Check Prometheus is running:**
```bash
docker ps | grep prometheus
```

**Check data sources in Grafana:**
1. Login to Grafana
2. Configuration → Data Sources
3. Should see Prometheus
4. Click "Test" - should be green

---

## 💾 Backup & Recovery

### Lost validator keys

**If you have seed phrase:**
```bash
cd /blockchain/helper
./key_mgmt.sh
# Choose "Restore from Seed Phrase"
```

**If you have backup:**
```bash
cd /blockchain/helper
./key_mgmt.sh
# Choose "Import from Backup"
```

**If you have nothing:**
- Unfortunately, keys are lost
- You'll need to exit validator and create new one

### System crashed during setup

**Check what was installed:**
```bash
docker ps -a
ls -la /blockchain
```

**Clean start:**
```bash
# Remove Docker containers
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

# Remove installation
sudo rm -rf /blockchain

# Run setup again
./setup_easy.sh
```

---

## 🔥 Emergency Procedures

### Need to exit validator immediately

```bash
cd /blockchain/helper
./emergency_exit.sh
```

### System running out of disk space

**Find what's using space:**
```bash
sudo du -h /blockchain | sort -rh | head -20
```

**Quick fixes:**
```bash
# Clean Docker
docker system prune -a

# Clean logs
sudo journalctl --vacuum-time=3d

# Clean apt cache
sudo apt clean
```

### Suspected slashing event

**Check validator status:**
```bash
# View logs
docker logs validator | grep -i slash

# Check on block explorer
# Visit: scan.pulsechain.com
# Search for your validator public key
```

**If slashed:**
1. **Stop validator immediately:**
   ```bash
   docker stop validator
   ```
2. **Check what caused it** (usually running duplicate keys)
3. **Fix the issue** before restarting
4. **Penalties are automatic** - cannot be reversed

---

## 📞 Getting More Help

### Before asking for help, collect this info:

```bash
# System info
uname -a
cat /etc/os-release

# Docker status
docker ps -a
docker logs execution --tail=50
docker logs beacon --tail=50

# Disk space
df -h

# Memory
free -h
```

### Where to get help:

1. **PulseDEV Telegram:** https://t.me/PulseDEV
2. **GitHub Issues:** https://github.com/poseidonPLS/install_pulse_node/issues
3. **Original repo:** https://github.com/tdslaine/install_pulse_node

### When asking for help, include:

- What you were trying to do
- What error message you got
- System info (from above)
- Relevant log snippets

---

## 🔧 Advanced Troubleshooting

### Enable debug logging

**For execution client:**
```bash
# Edit start script
sudo nano /blockchain/start_execution.sh

# Add debug flag
--verbosity 4
```

**For consensus client:**
```bash
# Edit start script
sudo nano /blockchain/start_consensus.sh

# Add debug flag (Lighthouse)
--debug-level debug
```

### Check system resources in real-time

```bash
# Install htop if not present
sudo apt install htop

# Monitor resources
htop
```

### Network diagnostics

```bash
# Check open connections
sudo netstat -tulnp

# Check bandwidth usage
sudo apt install iftop
sudo iftop
```

---

*This troubleshooting guide is maintained by the community. Found a solution not listed here? Please contribute!*

*Original setup by tdslaine • Enhanced by poseidonPLS*
