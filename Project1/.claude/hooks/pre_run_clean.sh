#!/bin/bash

echo "[HOOK] Cleaning workspace..."

rm -rf generated/* 2>/dev/null
rm -rf sim/logs/* 2>/dev/null
rm -rf obj_dir 2>/dev/null

mkdir -p generated
mkdir -p sim/logs

echo "[HOOK] Clean done"