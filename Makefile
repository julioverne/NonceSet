include theos/makefiles/common.mk

APPLICATION_NAME = NonceSet
NonceSet_FILES = NonceSet.mm
NonceSet_FRAMEWORKS = UIKit
NonceSet_PRIVATE_FRAMEWORKS = Preferences
NonceSet_CFLAGS = -fobjc-arc
NonceSet_LDFLAGS = -Wl,-segalign,4000
NonceSet_ARCHS = armv7 arm64
export ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/application.mk

all::
	@cp ./.theos/obj/debug/NonceSet.app/NonceSet //Applications/NonceSet.app/NonceSet
	@chown 0:0 //Applications/NonceSet.app/NonceSet
	@chmod 6755 //Applications/NonceSet.app/NonceSet