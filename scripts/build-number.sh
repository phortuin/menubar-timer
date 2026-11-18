#!/bin/sh
# Stamps CFBundleVersion with the git commit count: one number per commit
# (builds of the same commit, uncommitted changes included, share it). Runs
# as the app target's last script phase, with the processed Info.plist as its
# input, so it runs after Xcode writes that file and before code signing.
# Rewriting the git history lowers the count (accepted).
build=$(git -C "$SRCROOT" rev-list --count HEAD 2>/dev/null || echo 1)
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $build" "$TARGET_BUILD_DIR/$INFOPLIST_PATH"
