ARCHS = arm64 arm64e
FINALPACKAGE = 1
SYSROOT = $(THEOS)/sdks/iPhoneOS.sdk

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ForwardNotifier

ForwardNotifier_FILES = $(wildcard src/ForwardNotifierTweak/*.xm) $(wildcard src/ForwardNotifierTweak/*.m)
ForwardNotifier_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += src/ForwardNotifierPrefs src/ForwardNotifierCC src/ForwardNotifierReceiver src/ForwardNotifierRunner
include $(THEOS_MAKE_PATH)/aggregate.mk
