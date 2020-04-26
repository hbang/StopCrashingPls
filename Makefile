TARGET = iphone:latest:13.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AAAAAAstopcrashingpls

AAAAAAstopcrashingpls_FILES = Tweak.x

include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	mkdir -p $(THEOS_STAGING_DIR)/DEBIAN
	cp postinst $(THEOS_STAGING_DIR)/DEBIAN/postinst
	cp postinst $(THEOS_STAGING_DIR)/DEBIAN/postrm
