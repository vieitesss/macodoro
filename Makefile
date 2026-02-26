APP_NAME   = Macodoro
BUILD_DIR  = .build
APP_BUNDLE = $(BUILD_DIR)/$(APP_NAME).app

# Command Line Tools ship Testing.framework in a non-standard path; these flags
# let swift test compile and dynamically link it without Xcode.app installed.
FRAMEWORKS = /Library/Developer/CommandLineTools/Library/Developer/Frameworks
TEST_FLAGS = -Xswiftc -F -Xswiftc $(FRAMEWORKS) -Xlinker -rpath -Xlinker $(FRAMEWORKS)

.PHONY: build run restart test clean

build:
	swift build

test:
	swift test $(TEST_FLAGS)

## Build, assemble the .app bundle, and open it
run: build bundle
	open $(APP_BUNDLE)

## Kill the running instance (if any), then rebuild and launch
restart:
	-pkill $(APP_NAME)
	$(MAKE) run

## Assemble a minimal .app bundle from the compiled binary + Info.plist
bundle: build
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	cp $(BUILD_DIR)/debug/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	cp Info.plist $(APP_BUNDLE)/Contents/

clean:
	swift package clean
	rm -rf $(APP_BUNDLE)
