export ARCHS = armv7 armv7s  arm64

include theos/makefiles/common.mk


APPLICATION_NAME = UCNovelTool
UCNovelTool_FILES = main.m UCNovelToolApplication.mm RootViewController.mm
UCNovelTool_FRAMEWORKS = UIKit CoreGraphics

UCNovelTool_LDFLAGS += -lsqlite3
include $(THEOS_MAKE_PATH)/application.mk
