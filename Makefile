ARCHS = arm64 arm64e
FINALPACKAGE = 1
SYSROOT = $(THEOS)/sdks/iPhoneOS.sdk

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ForwardNotifier

ForwardNotifier_FILES = $(wildcard ForwardNotifierTweak/*.xm) $(wildcard ForwardNotifierTweak/*.m)
ForwardNotifier_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += ForwardNotifierPrefs
SUBPROJECTS += ForwardNotifierCC
SUBPROJECTS += ForwardNotifierReceiver
include $(THEOS_MAKE_PATH)/aggregate.mk
