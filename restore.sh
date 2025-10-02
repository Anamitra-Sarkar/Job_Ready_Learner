#!/bin/bash

# ================================================
# JOB READY PLATFORM - RESTORE FROM BACKUP SCRIPT
# ================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

BACKUP_DIR="./backups"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         🔓 JOB READY PLATFORM - RESTORE UTILITY            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if backup directory exists
if [ ! -d "${BACKUP_DIR}" ]; then
    echo -e "${RED}❌ Error: Backup directory not found!${NC}"
    exit 1
fi

# List available backups
echo -e "${YELLOW}📦 Available backups:${NC}"
echo ""

BACKUPS=($(find "${BACKUP_DIR}" -name "backup-*.tar.gz" -type f -printf "%T@ %f\n" 2>/dev/null | sort -rn | cut -d' ' -f2))

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo -e "${RED}❌ No backups found!${NC}"
    exit 1
fi

for i in "${!BACKUPS[@]}"; do
    BACKUP="${BACKUPS[$i]}"
    SIZE=$(du -sh "${BACKUP_DIR}/${BACKUP}" | cut -f1)
    DATE=$(echo "${BACKUP}" | grep -oP '\d{8}-\d{6}')
    FORMATTED_DATE=$(date -d "${DATE:0:8} ${DATE:9:2}:${DATE:11:2}:${DATE:13:2}" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "Unknown")
    echo -e "   ${CYAN}[$((i+1))]${NC} ${BACKUP}  (${SIZE}, ${FORMATTED_DATE})"
done

echo ""
echo -e "${YELLOW}⚠️  WARNING: This will overwrite current data!${NC}"
echo -e "${RED}Make sure to backup current data before restoring.${NC}"
echo ""

# Prompt for backup selection
read -p "Enter backup number to restore (1-${#BACKUPS[@]}), or 'q' to quit: " SELECTION

if [ "${SELECTION}" = "q" ] || [ "${SELECTION}" = "Q" ]; then
    echo -e "${CYAN}Restore cancelled.${NC}"
    exit 0
fi

# Validate selection
if ! [[ "${SELECTION}" =~ ^[0-9]+$ ]] || [ "${SELECTION}" -lt 1 ] || [ "${SELECTION}" -gt ${#BACKUPS[@]} ]; then
    echo -e "${RED}❌ Invalid selection!${NC}"
    exit 1
fi

SELECTED_BACKUP="${BACKUPS[$((SELECTION-1))]}"
BACKUP_PATH="${BACKUP_DIR}/${SELECTED_BACKUP}"

echo ""
echo -e "${YELLOW}Selected backup: ${SELECTED_BACKUP}${NC}"
echo ""

# Final confirmation
read -p "Are you sure you want to restore? (yes/no): " CONFIRM

if [ "${CONFIRM}" != "yes" ]; then
    echo -e "${CYAN}Restore cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}🔄 Restoring from backup...${NC}"

# Stop Docker containers if running
if command -v docker-compose &> /dev/null; then
    echo -e "${CYAN}Stopping Docker containers...${NC}"
    docker-compose down 2>/dev/null || true
fi

# Create backup of current data
if [ -d "./data" ]; then
    CURRENT_BACKUP="./backups/pre-restore-$(date +%Y%m%d-%H%M%S).tar.gz"
    echo -e "${CYAN}Backing up current data to: ${CURRENT_BACKUP}${NC}"
    tar -czf "${CURRENT_BACKUP}" ./data ./logs 2>/dev/null || true
fi

# Extract backup
if tar -xzf "${BACKUP_PATH}" -C . 2>/dev/null; then
    echo -e "${GREEN}✅ Restore completed successfully!${NC}"
    echo ""
    echo -e "${CYAN}📋 Next steps:${NC}"
    echo -e "   1. Review restored data in ./data/"
    echo -e "   2. Start services: ./docker-start.sh"
    echo ""
else
    echo -e "${RED}❌ Restore failed!${NC}"
    exit 1
fi

exit 0
