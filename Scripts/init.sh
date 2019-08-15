#!/bin/bash
git clone git@github.com:apple/swift-format.git swift-format
swift run captain uninstall
swift run captain install
