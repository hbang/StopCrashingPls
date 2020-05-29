TARGET = iphone:latest:13.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AAAAAAstopcrashingpls

ARCHS = arm64 arm64e

AAAAAAstopcrashingpls_FILES = Tweak.mm
AAAAAAstopcrashingpls_FRAMEWORKS = CoreFoundation
AAAAAAstopcrashingpls_CFLAGS = -w -framework

include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	mkdir -p $(THEOS_STAGING_DIR)/DEBIAN
	cp postinst $(THEOS_STAGING_DIR)/DEBIAN/postinst
	cp postinst $(THEOS_STAGING_DIR)/DEBIAN/postrm
