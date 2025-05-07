import shutil
import os

# ✏️ Customize these paths
SOURCE_DIR = "/Users/nullrider/Library/Mobile Documents/com~apple~CloudDocs/MyApps/NullRider/BasePackage/BasePackage/BasePackage"
TARGET_DIR = "/Users/nullrider/Library/Mobile Documents/com~apple~CloudDocs/MyApps/NullRiderCore/NullRiderCore/Sources/NullRiderCore"

# ✏️ List of relative file paths (from SOURCE_DIR) to copy
FILES_TO_COPY = [
    #"Core/AppSettingsManager/AppSettingsManager.swift",
    "Core/FileStorageHelper/FileStorageHelper.swift",
    "Core/KeychainHelper/KeychainHelper.swift",
    "Core/LocalDatabase/SwiftDataController.swift",
    "Core/LocalDatabase/Models/UserLogBookmark.swift",
    "Core/Logger/Logger.swift",
    "Core/Utilities/DateFormatterHelper.swift",
    #"Core/Utilities/EnvironmentConfig.swift",
    #"Core/Constants.swift",
    "Views/LogView.swift",
    "Views/LogBookmarkListView.swift",
    "UI/Components/PrimaryButton.swift",
    #"UI/Components/ThemedComponents.swift",
    "UI/Components/ToastManager.swift",
    "UI/Components/ToastOverlay.swift",
    "UI/Components/ToastView.swift"
    #"Extensions/ViewModifiers.swift",
    #"Theme/AppFont.swift",
    #"UI/Components/ThemeManager.swift"
]

def test_folder_paths():
    print("🧪 Testing folder paths...\n")
    source_abs = os.path.abspath(SOURCE_DIR)
    target_abs = os.path.abspath(TARGET_DIR)

    print(f"🔍 Source Directory: {source_abs}")
    print(f"🔍 Target Directory: {target_abs}")

    source_ok = os.path.isdir(source_abs)
    target_ok = os.path.isdir(target_abs)

    if source_ok:
        print("✅ Source directory exists")
    else:
        print("❌ Source directory not found!")

    if target_ok:
        print("✅ Target directory exists")
    else:
        print("❌ Target directory not found!")

    return source_ok and target_ok

def sync_files():
    print("🔄 Syncing files from BasePackage to NullRiderCore...\n")
    for relative_path in FILES_TO_COPY:
        # print(f"{relative_path}\n")
        src_path = os.path.join(SOURCE_DIR, relative_path)
        #src_path = f"{SOURCE_DIR}/{relative_path}"
        # src_path = relative_path
        # print(f"{src_path}")
        # print("\n")
        dst_path = os.path.join(TARGET_DIR, os.path.basename(relative_path))  # Flatten structure

        if not os.path.exists(src_path):
            print(f"⚠️  Source file not found: {src_path}\n")
            continue

        try:
            shutil.copy2(src_path, dst_path)
            # print(f"✅ Copied: {relative_path} → {os.path.basename(dst_path)}")
        except Exception as e:
            print(f"❌ Failed to copy {relative_path}: {e}")

    print("\n✅ Done.")

if __name__ == "__main__":
    # test_folder_paths()
    sync_files()
