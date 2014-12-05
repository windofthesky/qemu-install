VERSION=2.1.2

LIBAIO_VERSION=0.3.110
GUESTFISH_VERSION_MAJOR=1.28
GUESTFISH_VERSION_MINOR=4
GUESTFISH_VERSION=$(GUESTFISH_VERSION_MAJOR).$(GUESTFISH_VERSION_MINOR)
APPLIANCE_VERSION=1.28.1
LIBXML2_VERSION=2.9.2

export PREFIX := /lustre_cfc/software/qbic/qemu/$(VERSION)
export PATH := $(PREFIX)/bin:$(PREFIX)/share/bin:$(PATH)
export LIBRARY_PATH := $(PREFIX)/share/lib:$(PREFIX)/lib
export C_INCLUDE_PATH := $(PREFIX)/share/include:$(PREFIX)/include
export PKG_CONFIG_PATH := $(PREFIX)/share/lib/pkgconfig

all : guestfish.installed

qemu.installed : libaio.installed
	wget -nc "http://wiki.qemu-project.org/download/qemu-$(VERSION).tar.bz2"
	sha256sum -c qemu-$(VERSION).tar.bz2.sha256
	tar xf qemu-$(VERSION).tar.bz2
	cd qemu-$(VERSION) && source ../build.sh
	touch $@


libaio.installed :
	wget -nc "http://ftp.de.debian.org/debian/pool/main/liba/libaio/libaio_$(LIBAIO_VERSION).orig.tar.gz"
	sha256sum -c libaio_$(LIBAIO_VERSION).orig.tar.gz.sha256
	tar xf libaio_$(LIBAIO_VERSION).orig.tar.gz
	cd libaio-$(LIBAIO_VERSION) && make prefix=$(PREFIX)/share install
	touch $@


guestfish.installed : qemu.installed libxml2.installed gperf.installed pcre.installed augeas.installed
	wget -nc "http://libguestfs.org/download/$(GUESTFISH_VERSION_MAJOR)-stable/libguestfs-$(GUESTFISH_VERSION).tar.gz"
	wget -nc "http://libguestfs.org/download/binaries/appliance/appliance-$(APPLIANCE_VERSION).tar.xz"
	sha256sum -c libguestfs-$(GUESTFISH_VERSION).tar.gz.sha256
	tar xf libguestfs-$(GUESTFISH_VERSION).tar.gz
	tar xf appliance-$(APPLIANCE_VERSION).tar.xz -C $(PREFIX)/share
	cd libguestfs-$(GUESTFISH_VERSION) && \
		./configure --disable-appliance --disable-daemon --with-qemu=qemu-system-x86_64 --without-libvirt --prefix=$(PREFIX) && \
		make -j20 && \
		make install
	touch $@

libxml2.installed : 
	wget -nc "ftp://xmlsoft.org/libxml2/libxml2-$(LIBXML2_VERSION).tar.gz"
	tar xf libxml2-$(LIBXML2_VERSION).tar.gz
	cd libxml2-$(LIBXML2_VERSION) && \
		./configure --prefix=$(PREFIX)/share --without-python && \
		make -j20 && \
		make install
	touch $@


gperf.installed :
	wget -nc "http://ftp.gnu.org/pub/gnu/gperf/gperf-3.0.4.tar.gz"
	sha256sum -c gperf-3.0.4.tar.gz
	tar xf gperf-3.0.4.tar.gz
	cd gperf-3.0.4 && \
		./configure --prefix=$(PREFIX)/share && \
		make -j20 && \
		make install
	touch $@


pcre.installed :
	wget -nc "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.36.tar.gz"
	sha256sum -c pcre-8.36.tar.gz
	tar xf pcre-8.36.tar.gz
	cd pcre-8.36 && \
		./configure --prefix=$(PREFIX)/share && \
		make -j20 && \
		make install
	touch $@


augeas.installed :
	wget -nc "http://download.augeas.net/augeas-1.3.0.tar.gz"
	sha256sum -c augeas-1.3.0.tar.gz.sha256
	tar xf augeas-1.3.0.tar.gz
	cd augeas-1.3.0 && \
		./configure --prefix=$(PREFIX)/share && \
		make -j20 && \
		make install
	touch $@
