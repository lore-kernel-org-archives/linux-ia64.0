From: Keith Owens <kaos@ocs.com.au>
Date: Sun, 02 Dec 2001 04:23:01 +0000
Subject: [Linux-ia64] No include/asm-ia64/mmzone.h in 2.4.16-ia64-011128
Message-Id: <marc-linux-ia64-105590698805569@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I tried compiling 2.4.16-ia64-011128 as type SGI-SN1.  It broke at
include/linux/mmzone.h:138 trying to include asm/mmzone.h which does
not exist on ia64.  Is ia64-011128 supposed to compile sn1/sn2 out of
the box or are there extra patches required?

Also this does not look right in arch/ia64/Makefile.  GENERIC and
SGI_SN do not agree on the core files and subirs, does anybody ever use
generic?

ifdef CONFIG_IA64_GENERIC
        CORE_FILES      :=      arch/$(ARCH)/hp/hp.a    \
                                arch/$(ARCH)/sn/sn.o    \
                                arch/$(ARCH)/dig/dig.a  \
                                arch/$(ARCH)/sn/io/sgiio.o \
                                $(CORE_FILES)
        SUBDIRS         :=      arch/$(ARCH)/hp         \
                                arch/$(ARCH)/sn/sn1     \
                                arch/$(ARCH)/sn         \
                                arch/$(ARCH)/dig        \
                                arch/$(ARCH)/sn/io      \
                                $(SUBDIRS)

else # !GENERIC

....

ifdef CONFIG_IA64_SGI_SN
        CFLAGS          += -DBRINGUP
        SUBDIRS         :=      arch/$(ARCH)/sn/kernel  \
                                arch/$(ARCH)/sn/io      \
                                arch/$(ARCH)/sn/fakeprom        \
                                $(SUBDIRS)
        CORE_FILES      :=      arch/$(ARCH)/sn/kernel/sn.o     \
                                arch/$(ARCH)/sn/io/sgiio.o      \
                                $(CORE_FILES)
endif

At the subject of arch/ia64/Makefile, it tests for CONFIG_IA64_SOFTSDV
but nothing else in the kernel refers to that variable, it cannot be
set.


