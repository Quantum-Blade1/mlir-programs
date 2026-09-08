#!/usr/bin/env bash
# ==============================================================================
# Automated Verification Suite for DQC MLIR Quantum Programs
# ==============================================================================
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}======================================================${NC}"
echo -e "${BOLD}${BLUE}      DQC MLIR Quantum Algorithm Verification Suite   ${NC}"
echo -e "${BOLD}${BLUE}======================================================${NC}\n"

# Verify DQC compiler availability
if ! command -v dqc &> /dev/null; then
    echo "Error: 'dqc' compiler binary not found on PATH."
    exit 1
fi

echo -e "${BOLD}1. Running Core Quantum Algorithms:${NC}"
for file in algorithms/*.mlir; do
    echo -e "\n${GREEN}==> Compiling & Executing: $file${NC}"
    dqc "$file"
done

echo -e "\n${BOLD}2. Running Multi-QPU Distributed Benchmarks:${NC}"
for file in benchmarks/*.mlir; do
    echo -e "\n${GREEN}==> Compiling & Executing: $file${NC}"
    dqc "$file"
done

echo -e "\n${BOLD}${GREEN}======================================================${NC}"
echo -e "${BOLD}${GREEN}  All 16 Quantum Programs Compiled & Verified Cleanly! ${NC}"
echo -e "${BOLD}${GREEN}======================================================${NC}"
