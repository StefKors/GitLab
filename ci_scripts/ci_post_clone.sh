#!/bin/sh
# source: https://forums.swift.org/t/tcas-macros-and-ci-cd/71104/8
# Exit on error (-e), undefined vars (-u), and pipeline failures (-o pipefail)

set -euo pipefail

# Disable Xcode macro fingerprint validation to prevent spurious build errors

defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES