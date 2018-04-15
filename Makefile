# fallback to the current kernel source
KSRC ?= /lib/modules/$(shell uname -r)/build

KMOD_SRC ?= $(CURDIR)/rtlwifi

KMOD_OPTIONS = CONFIG_RTL_CARDS=y
KMOD_OPTIONS += CONFIG_RTLWIFI=m
KMOD_OPTIONS += CONFIG_RTLWIFI_DEBUG=n
KMOD_OPTIONS += CONFIG_RTLWIFI_DEBUGFS=n
KMOD_OPTIONS += CONFIG_RTLWIFI_USB=m
KMOD_OPTIONS += CONFIG_RTLWIFI_PCI=n
KMOD_OPTIONS += CONFIG_RTL8192SU=m
KMOD_OPTIONS += CONFIG_RTL8192SE=n
KMOD_OPTIONS += CONFIG_RTL8192S_COMMON=m

# Don't build any of the other drivers
KMOD_OPTIONS += CONFIG_RTL8192CU=n CONFIG_RTL8192DE=n CONFIG_RTL8192CE=n CONFIG_RTL8192C_COMMON=n CONFIG_RTL8723AE=n CONFIG_RTL8188EE=n

EXTRA_CFLAGS += -DDEBUG -DCONFIG_RTLWIFI_DEBUGFS=m

all:
	$(MAKE) -C $(KSRC) M=$(KMOD_SRC) $(KMOD_OPTIONS) $(MAKECMDGOALS) EXTRA_CFLAGS="$(EXTRA_CFLAGS)"

.PHONY: all clean load unload reload test

clean:
	$(MAKE) -C $(KSRC) M=$(KMOD_SRC) clean $(KMOD_OPTIONS)

load:
	modprobe mac80211
	insmod $(KMOD_SRC)/rtlwifi.ko
	insmod $(KMOD_SRC)/rtl_usb.ko
	insmod $(KMOD_SRC)/rtl8192s/rtl8192s-common.ko
	insmod $(KMOD_SRC)/rtl8192su/rtl8192su.ko

loadpci:
	modprobe mac80211
	insmod $(KMOD_SRC)/rtlwifi.ko
	insmod $(KMOD_SRC)/rtl_pci.ko
	insmod $(KMOD_SRC)/rtl8192s/rtl8192s-common.ko
	insmod $(KMOD_SRC)/rtl8192se/rtl8192se.ko

unload:
	rmmod rtl8192se || echo "rtl8192se not loaded"
	rmmod rtl8192su || echo "rtl8192su not loaded"
	rmmod rtl8192s-common || echo "rtl8192s-common not loaded"
	rmmod rtl_pci	|| echo "rtl_pci not loaded"
	rmmod rtl_usb   || echo "rtl_usb not loaded"
	rmmod rtlwifi   || echo "rtlwifi not loaded"

reload: unload load

test: all reload
