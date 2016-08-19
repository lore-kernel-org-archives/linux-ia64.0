From: mcgrof@kernel.org
Date: Fri, 19 Aug 2016 21:34:01 +0000
Subject: [PATCH v4 03/16] scripts/module-common.lds: enable generation
Message-Id: <1471642454-5679-4-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: gnomes@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, linux@rasmusvillemoes.dk, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, sparclinux@vger.kernel.org, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, xen-devel@lists.xensource.com, msalter@redhat.com, linux-sh@vger.kernel.org, mpe@ellerman.id.au, x86@kernel.org, fontana@sharpeleven.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, linux-xtensa@linux-xtensa.org, pali.rohar@gmail.com, keescook@chromium.org, arnd@arndb.de, jani.nikula@intel.com, will.deacon@arm.com, rusty@rustcorp.com.au, rostedt@goodmis.org, acme@redhat.com, ak@linux.intel.com, andriy.shevchenko@linux.intel.com, mcb30@ip

From: "Luis R. Rodriguez" <mcgrof@kernel.org>

scripts/module-common.lds is currently pretty static, in the
future this may change and we will want access to kernel macros
to help expands certain areas. To get access to use macros we
need to generate module-common.lds from module-common.lds.S, for
now though only enable the generation. We'll later expand on this
as needed.

Since this file is now generated add it to .gitignore.

v4: add file to MAINTAINERS
v3: new to this series

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 .gitignore                                         | 2 ++
 MAINTAINERS                                        | 1 +
 Makefile                                           | 6 +++++-
 scripts/Makefile.modpost                           | 2 +-
 scripts/{module-common.lds => module-common.lds.S} | 0
 5 files changed, 9 insertions(+), 2 deletions(-)
 rename scripts/{module-common.lds => module-common.lds.S} (100%)

diff --git a/.gitignore b/.gitignore
index c2ed4ecb0acd..0f0702054fdb 100644
--- a/.gitignore
+++ b/.gitignore
@@ -114,3 +114,5 @@ all.config
 
 # Kdevelop4
 *.kdev4
+
+scripts/module-common.lds
diff --git a/MAINTAINERS b/MAINTAINERS
index d635ab047f3a..5aec01883020 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7887,6 +7887,7 @@ M:	Rusty Russell <rusty@rustcorp.com.au>
 S:	Maintained
 F:	include/linux/module.h
 F:	kernel/module.c
+F:	scripts/module-common.lds.S
 
 MOTION EYE VAIO PICTUREBOOK CAMERA DRIVER
 W:	http://popies.net/meye/
diff --git a/Makefile b/Makefile
index 5c18baad7218..b3e5ea78d582 100644
--- a/Makefile
+++ b/Makefile
@@ -408,6 +408,10 @@ KBUILD_AFLAGS_MODULE  := -DMODULE
 KBUILD_CFLAGS_MODULE  := -DMODULE
 KBUILD_LDFLAGS_MODULE := -T $(srctree)/scripts/module-common.lds
 
+$(srctree)/scripts/module-common.lds: $(srctree)/scripts/module-common.lds.S
+	$(Q)$(CC) $(CFLAGS) $(INCLUDES) $(LINUXINCLUDE) -E -P \
+		-D__ASSEMBLY__ -DLINKER_SCRIPT -o $@ $<
+
 # Read KERNELRELEASE from include/config/kernel.release (if it exists)
 KERNELRELEASE = $(shell cat include/config/kernel.release 2> /dev/null)
 KERNELVERSION = $(VERSION)$(if $(PATCHLEVEL),.$(PATCHLEVEL)$(if $(SUBLEVEL),.$(SUBLEVEL)))$(EXTRAVERSION)
@@ -1174,7 +1178,7 @@ all: modules
 # using awk while concatenating to the final file.
 
 PHONY += modules
-modules: $(vmlinux-dirs) $(if $(KBUILD_BUILTIN),vmlinux) modules.builtin
+modules: $(srctree)/scripts/module-common.lds $(vmlinux-dirs) $(if $(KBUILD_BUILTIN),vmlinux) modules.builtin
 	$(Q)$(AWK) '!x[$$0]++' $(vmlinux-dirs:%=$(objtree)/%/modules.order) > $(objtree)/modules.order
 	@$(kecho) '  Building modules, stage 2.';
 	$(Q)$(MAKE) -f $(srctree)/scripts/Makefile.modpost
diff --git a/scripts/Makefile.modpost b/scripts/Makefile.modpost
index 1366a94b6c39..2d8aff7735d6 100644
--- a/scripts/Makefile.modpost
+++ b/scripts/Makefile.modpost
@@ -121,7 +121,7 @@ quiet_cmd_ld_ko_o = LD [M]  $@
                              $(KBUILD_LDFLAGS_MODULE) $(LDFLAGS_MODULE) \
                              -o $@ $(filter-out FORCE,$^)
 
-$(modules): %.ko :%.o %.mod.o FORCE
+$(modules): %.ko : $(srctree)/scripts/module-common.lds %.o %.mod.o FORCE
 	$(call if_changed,ld_ko_o)
 
 targets += $(modules)
diff --git a/scripts/module-common.lds b/scripts/module-common.lds.S
similarity index 100%
rename from scripts/module-common.lds
rename to scripts/module-common.lds.S
-- 
2.9.2

