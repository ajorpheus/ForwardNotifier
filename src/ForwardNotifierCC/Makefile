ARCHS = arm64 arm64e
SYSROOT = $(THEOS)/sdks/iPhoneOS.sdk

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ForwardNotifierCC
ForwardNotifierCC_BUNDLE_EXTENSION = bundle
ForwardNotifierCC_FILES = ForwardNotifierCC.m
ForwardNotifierCC_PRIVATE_FRAMEWORKS = ControlCenterUIKit
ForwardNotifierCC_INSTALL_PATH = /Library/ControlCenter/Bundles/

#after-install::
#	install.exec "killall -9 SpringBoard"

include $(THEOS_MAKE_PATH)/bundle.mk
