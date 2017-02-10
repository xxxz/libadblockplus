HOST_ARCH=$(shell python ./third_party/v8/gypfiles/detect_v8_host_arch.py)
ARCH := ${HOST_ARCH}

ifndef OS
  raw_OS = $(shell uname -s)
  ifeq (${raw_OS},Linux)
    OS=linux
  else ifeq (${raw_OS},Darwin)
    OS=mac
  endif
endif

ANDROID_PARAMETERS = OS=android
ifneq ($(ANDROID_ARCH),)
ifeq ($(ANDROID_ARCH),arm)
ANDROID_PARAMETERS += target_arch=arm
ANDROID_ABI = armeabi-v7a
else ifeq ($(ANDROID_ARCH),ia32)
ANDROID_PARAMETERS += target_arch=x86 android_target_arch=x86
ANDROID_ABI = x86
else
$(error "Unsupported Android architecture: $(ANDROID_ARCH))
endif
ANDROID_DEST_DIR = android_$(ANDROID_ARCH).release
endif

TEST_EXECUTABLE = build/out/Debug/tests

.PHONY: all test clean docs v8 v8_android_multi android_multi android_x86 \
	android_arm ensure_dependencies

.DEFAULT_GOAL:=all

ensure_dependencies:
	python ensure_dependencies.py

v8: ensure_dependencies
	third_party/gyp/gyp --depth=. -f make -I v8.gypi --generator-output=build/v8 -Dtarget_arch=${ARCH} -Dhost_arch=${HOST_ARCH} third_party/v8/src/v8.gyp
	make -C build/v8 v8_maybe_snapshot v8_libplatform v8_libsampler

all: v8
	GYP_DEFINES=OS=${OS} third_party/gyp/gyp --depth=. -f make -I libadblockplus.gypi --generator-output=build -Dtarget_arch=${ARCH} -Dhost_arch=${HOST_ARCH} libadblockplus.gyp
	$(MAKE) -C build

test: all
ifdef FILTER
	$(TEST_EXECUTABLE) --gtest_filter=$(FILTER)
else
	$(TEST_EXECUTABLE)
endif

docs:
	doxygen

clean:
	$(RM) -r build docs

android_x86:
	ANDROID_ARCH="ia32" $(MAKE) android_multi

android_arm:
	ANDROID_ARCH="arm" $(MAKE) android_multi

ifneq ($(ANDROID_ARCH),)
v8_android_multi:
	make -C third_party/v8 -f Makefile.android android_${ANDROID_ARCH}.release snapshot=off ARCH=android_${ANDROID_ARCH} MODE=release OUTDIR=../../build/ GYPFLAGS=-I../../android-v8-options.gypi

android_multi: v8_android_multi
	GYP_DEFINES="${ANDROID_PARAMETERS} ANDROID_ARCH=$(ANDROID_ARCH)" \
	./make_gyp_wrapper.py --depth=. -f make-android -Dhost_arch=${HOST_ARCH} -Dtarget_arch=${ANDROID_ARCH} -Iandroid-v8-options.gypi --generator-output=build -Gandroid_ndk_version=r9 libadblockplus.gyp
	$(ANDROID_NDK_ROOT)/ndk-build -C build installed_modules \
	BUILDTYPE=Release \
	APP_ABI=$(ANDROID_ABI) \
	APP_PLATFORM=android-9 \
	APP_STL=c++_static \
	APP_BUILD_SCRIPT=Makefile \
	NDK_PROJECT_PATH=. \
	NDK_OUT=. \
	NDK_APP_DST_DIR=$(ANDROID_DEST_DIR)
endif

