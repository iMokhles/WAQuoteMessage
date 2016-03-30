GO_EASY_ON_ME = 1

DEBUG = 0

THEOS_DEVICE_IP = localhost

ARCHS = armv7 armv7s arm64

TARGET = iphone:clang:latest:5.0

ADDITIONAL_LDFLAGS = -Wl,-segalign,4000

THEOS_BUILD_DIR = Packages

include theos/makefiles/common.mk

TWEAK_NAME = WAQuoteMessage
WAQuoteMessage_FILES = Tweak.xm MBProgressHUD.m
WAQuoteMessage_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore CoreImage Accelerate AVFoundation AudioToolbox MobileCoreServices Social Accounts MediaPlayer
WAQuoteMessage_LIBRARIES =  z sqlite3 MobileGestalt substrate

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WhatsApp"
