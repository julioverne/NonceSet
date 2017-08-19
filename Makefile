include theos/makefiles/common.mk

APPLICATION_NAME = NonceSet
NonceSet_FILES = /mnt/d/codes/nonceset/NonceSet.mm
NonceSet_FRAMEWORKS = UIKit Foundation CoreGraphics
NonceSet_PRIVATE_FRAMEWORKS = Preferences
NonceSet_LIBRARIES = MobileGestalt
NonceSet_CFLAGS = -fobjc-arc
NonceSet_LDFLAGS = -Wl,-segalign,4000
NonceSet_ARCHS = armv7 arm64
export ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/application.mk

all::
