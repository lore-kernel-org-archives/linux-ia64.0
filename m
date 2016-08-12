From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Fri, 12 Aug 2016 06:50:11 +0000
Subject: Re: [RFC v3 07/13] tables.h: add linker table support
Message-Id: <20160812065011.GB3296@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
 <1469222687-1600-8-git-send-email-mcgrof@kernel.org>
 <20160729100630.GA27271@nazgul.tnic>
 <20160808150539.GG3296@wotan.suse.de>
 <20160809035508.GC11445@nazgul.tnic>
 <20160812035129.GA3296@wotan.suse.de>
 <20160812052303.GB12013@nazgul.tnic>
In-Reply-To: <20160812052303.GB12013@nazgul.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Borislav Petkov <bp@alien8.de>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel

On Fri, Aug 12, 2016 at 07:23:03AM +0200, Borislav Petkov wrote:
> On Fri, Aug 12, 2016 at 05:51:29AM +0200, Luis R. Rodriguez wrote:
> > OK I've added CONFIG_BUILD_AVOID_BITROT.
> 
> What does that do?


Enabling it allows the forced compilation chosen by maintainers.
Otherwise forced compilations with the new special targets are
ignored. I've gone with table-obj-y and table-lib-y as we have
to support both lib-y and obj-y respective targets.

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 33e2966dd741..7893e3b8da82 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1895,6 +1895,30 @@ config PROVIDE_OHCI1394_DMA_INIT
 
 	  See Documentation/debugging-via-ohci1394.txt for more information.
 
+config BUILD_AVOID_BITROT
+	bool "Always force building specially annotated"
+	default y
+	help
+	  If enabled then the the special table-* Makefile targets will always
+	  be forced to be compiled even if their respective CONFIG_ option has
+	  been disabled, but its objects will only be linked in if the same
+	  respective CONFIG_ option has been enabled. This helps avoid code
+	  bit rot issues, use for these targets should be carefully considred
+	  by maintainers. You can safely enable this option at the expense of
+	  increasing compile time slightly. Enabling this option helps avoid
+	  code bit rot by taking advantage of the facilities provided and
+	  enabled by using linker tables documented under:
+
+	  include/linux/tables.h
+
+	  The special targets supported are:
+
+	    o table-obj-y
+	    o table-lib-y
+
+	  Say Y unless you are a grumpy maintainer and don't trust other
+	  maintainer's judgements on what code should always get compiled.
+
 config BUILD_DOCSRC
 	bool "Build targets in Documentation/ tree"
 	depends on HEADERS_CHECK
diff --git a/scripts/Makefile.build b/scripts/Makefile.build
index 002857fe8d0d..17ced5ac44b2 100644
--- a/scripts/Makefile.build
+++ b/scripts/Makefile.build
@@ -91,7 +91,8 @@ modorder-target := $(obj)/modules.order
 
 # We keep a list of all modules in $(MODVERDIR)
 
-__build: $(if $(KBUILD_BUILTIN),$(builtin-target) $(lib-target) $(extra-y) $(table-y)) \
+__build: $(if $(KBUILD_BUILTIN),$(builtin-target) $(lib-target) $(extra-y) \
+				$(table-obj-y)) \
 	 $(if $(KBUILD_MODULES),$(obj-m) $(modorder-target)) \
 	 $(subdir-ym) $(always)
 	@:
@@ -325,8 +326,8 @@ cmd_as_o_S       = $(CC) $(a_flags) -c -o $@ $<
 $(obj)/%.o: $(src)/%.S $(objtool_obj) FORCE
 	$(call if_changed_rule,as_o_S)
 
-targets += $(real-objs-y) $(real-objs-m) $(lib-y)
-targets += $(extra-y) $(table-y) $(MAKECMDGOALS) $(always)
+targets += $(real-objs-y) $(real-objs-m) $(lib-y) $(table-lib-y)
+targets += $(extra-y) $(table-obj-y) $(MAKECMDGOALS) $(always)
 
 # Linker scripts preprocessor (.lds.S -> .lds)
 # ---------------------------------------------------------------------------
diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
index 494f215ebaa4..58db6b503aca 100644
--- a/scripts/Makefile.lib
+++ b/scripts/Makefile.lib
@@ -12,15 +12,14 @@ export KBUILD_SUBDIR_CCFLAGS := $(KBUILD_SUBDIR_CCFLAGS) $(subdir-ccflags-y)
 # Figure out what we need to build from the various variables
 # ===================================== 
-# Linker tables objects always wish to be built to avoid bit-rot in
-# code, but only linked in *iff* they were enabled. We accomplish this
-# using pegging linker table objects into extra-y, which forces
-# compilation and then using the respective table-y and table-m as
-# as hints for things we do want enabled. Objects which we want to
-# avoid linking in will be in table-, not table-y and table-m.
-extra-y += $(table-)
-obj-m += $(table-m)
-obj-y += $(table-y)
+ifeq ($(CONFIG_BUILD_AVOID_BITROT),y)
+extra-y += $(table-obj-) $(table-lib-)
+endif
+
+obj-m += $(table-obj-m)
+obj-y += $(table-obj-y)
+lib-m += $(table-lib-m)
+lib-y += $(table-lib-y)
 
 # When an object is listed to be built compiled-in and modular,
 # only build the compiled-in version
@@ -82,8 +81,8 @@ real-objs-m := $(foreach m, $(obj-m), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y)
 # Add subdir path
 
 extra-y		:= $(addprefix $(obj)/,$(extra-y))
-table-y		:= $(addprefix $(obj)/,$(table-y))
-table-m		:= $(addprefix $(obj)/,$(table-m))
+table-obj-y		:= $(addprefix $(obj)/,$(table-obj-y))
+table-obj-m		:= $(addprefix $(obj)/,$(table-obj-m))
 always		:= $(addprefix $(obj)/,$(always))
 targets		:= $(addprefix $(obj)/,$(targets))
 modorder	:= $(addprefix $(obj)/,$(modorder))
