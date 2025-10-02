#!/bin/bash

# ================================================
# JOB READY PLATFORM - AUTOMATED BACKUP SCRIPT
# Daily backups with retention policy
# ================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
BACKUP_DIR="./backups"
DATA_DIR="./data"
LOGS_DIR="./logs"
RETENTION_DAYS=30
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_FILE="backup-${TIMESTAMP}.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           🔒 JOB READY PLATFORM - BACKUP UTILITY           ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if data directory exists
if [ ! -d "${DATA_DIR}" ]; then
    echo -e "${RED}❌ Error: Data directory '${DATA_DIR}' not found!${NC}"
    exit 1
fi

echo -e "${YELLOW}📊 Backup Information:${NC}"
echo -e "   Source: ${DATA_DIR}"
echo -e "   Destination: ${BACKUP_DIR}/${BACKUP_FILE}"
echo -e "   Retention: ${RETENTION_DAYS} days"
echo -e "   Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Calculate data size
DATA_SIZE=$(du -sh "${DATA_DIR}" 2>/dev/null | cut -f1)
echo -e "${CYAN}📦 Data size: ${DATA_SIZE}${NC}"
echo ""

# Create backup
echo -e "${YELLOW}🔄 Creating backup...${NC}"

if tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" \
    -C . \
    "${DATA_DIR#./}" \
    "${LOGS_DIR#./}" 2>/dev/null; then
    
    BACKUP_SIZE=$(du -sh "${BACKUP_DIR}/${BACKUP_FILE}" | cut -f1)
    echo -e "${GREEN}✅ Backup created successfully!${NC}"
    echo -e "   File: ${BACKUP_FILE}"
    echo -e "   Size: ${BACKUP_SIZE}"
else
    echo -e "${RED}❌ Backup failed!${NC}"
    exit 1
fi

echo ""

# Verify backup integrity
echo -e "${YELLOW}🔍 Verifying backup integrity...${NC}"

if tar -tzf "${BACKUP_DIR}/${BACKUP_FILE}" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Backup integrity verified${NC}"
else
    echo -e "${RED}❌ Backup verification failed!${NC}"
    rm -f "${BACKUP_DIR}/${BACKUP_FILE}"
    exit 1
fi

echo ""

# Cleanup old backups
echo -e "${YELLOW}🧹 Cleaning up old backups (older than ${RETENTION_DAYS} days)...${NC}"

DELETED_COUNT=0
while IFS= read -r -d '' OLD_BACKUP; do
    echo -e "   ${RED}Deleting:${NC} $(basename "${OLD_BACKUP}")"
    rm -f "${OLD_BACKUP}"
    ((DELETED_COUNT++))
done < <(find "${BACKUP_DIR}" -name "backup-*.tar.gz" -type f -mtime +${RETENTION_DAYS} -print0 2>/dev/null)

if [ ${DELETED_COUNT} -gt 0 ]; then
    echo -e "${GREEN}✅ Deleted ${DELETED_COUNT} old backup(s)${NC}"
else
    echo -e "${CYAN}ℹ️  No old backups to delete${NC}"
fi

echo ""

# List current backups
BACKUP_COUNT=$(find "${BACKUP_DIR}" -name "backup-*.tar.gz" -type f 2>/dev/null | wc -l)
TOTAL_BACKUP_SIZE=$(du -sh "${BACKUP_DIR}" 2>/dev/null | cut -f1)

echo -e "${CYAN}📋 Backup Summary:${NC}"
echo -e "   Total backups: ${BACKUP_COUNT}"
echo -e "   Total size: ${TOTAL_BACKUP_SIZE}"
echo -e "   Location: ${BACKUP_DIR}/"
echo ""

# Display recent backups
echo -e "${CYAN}📦 Recent backups:${NC}"
find "${BACKUP_DIR}" -name "backup-*.tar.gz" -type f -printf "%TY-%Tm-%Td %TH:%TM  %f  %s bytes\n" 2>/dev/null | sort -r | head -5 | while read line; do
    echo -e "   ${line}"
done

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    ✅ BACKUP COMPLETED                      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Generate backup report
REPORT_FILE="${BACKUP_DIR}/backup-report.txt"
{
    echo "JOB READY PLATFORM - BACKUP REPORT"
    echo "=================================="
    echo ""
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Backup File: ${BACKUP_FILE}"
    echo "Backup Size: ${BACKUP_SIZE}"
    echo "Data Size: ${DATA_SIZE}"
    echo "Total Backups: ${BACKUP_COUNT}"
    echo "Retention Policy: ${RETENTION_DAYS} days"
    echo "Deleted Old Backups: ${DELETED_COUNT}"
    echo ""
    echo "Recent Backups:"
    find "${BACKUP_DIR}" -name "backup-*.tar.gz" -type f -printf "%TY-%Tm-%Td %TH:%TM  %f\n" 2>/dev/null | sort -r | head -10
} > "${REPORT_FILE}"

echo -e "${CYAN}📄 Report saved to: ${REPORT_FILE}${NC}"
echo ""

exit 0
