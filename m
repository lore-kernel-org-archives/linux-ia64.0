From: mcgrof@kernel.org
Date: Fri, 19 Aug 2016 21:34:06 +0000
Subject: [PATCH v4 08/16] kbuild: enable option to force compile force-obj-y and force-lib-y
Message-Id: <1471642454-5679-9-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel.org, ton

From: "Luis R. Rodriguez" <mcgrof@kernel.org>

Linux provides a rich array of features, enabling each feature
however increases the size of the kernel and there are many
features which users often want disabled. The traditional
solution to this problem is for each feature to have its own
Kconfig symbol, followed by a series of #ifdef statements
in C code and header files, allowing the feature to be compiled
only when desirable. As the variability of Linux increases build
tests can and are often done with random kernel configurations,
allyesconfig, and allmodconfig to help find code issues. This
however doesn't catch all errors and as a consequence code that
is typically not enabled often can suffer from bit-rot over time.

An alternative approach for subsystems, which refer to as the 'build-all
link-selectively philosophy' is to keep the Kconfig symbols, replace
the #ifdef approach by having each feature implemented it its own C file,
and force compilation for all features to avoid the code bit-rot problem.
With this strategy only features that are enabled via Kconfig get
linked into the kernel, so the forced compilation has no size impact
on the kernel. The practice of having each feature implemented in its own
C file is already prevalent in many subsystems, however #ifdefs are still
typically required during feature initialization. For instance in:

  #ifdef CONFIG_FOO
  foo_init();
  #endif

We cannot remove the #ifdef and leave foo_init() as we'd either
need to always enable the feature or add a respective #ifdef in a
foo.h which makes foo_init() do nothing when CONFIG_FOO is disabled.

Linker tables enable lifting the requirement to use of #ifdefs during
initialization. With linker tables initialization sequences can instead
be aggregated into a custom ELF section at link time, during run time
the table can be iterated over and each init sequence enabled can be called.
A feature's init routine is only added to a table when its respective
Kconfig symbols has been enabled and therefore linked in. Linker tables
enable subsystems to completely do away with #ifdefs if one is comfortable
in accepting all subsystem's feature's structural size implications.

Subsystems which want to follow the 'build-all link-selectively
philosophy' still need a way to easily express and annotate that they
wish for all code to always be compiled to help avoid code bit rot,
as such two new targets force-obj-y and force-lib-y are provided to
help with this. Its not fair to require everyone to force compilation
of all features of a subsystem though, so as a compromise, the new
targets only force compilation when CONFIG_BUILD_AVOID_BITROT is
enabled.

Only built-in features are supported at the moment. Module support
is expected to be added after a generic solution to add linker
tables to modules more easily is developed.

v4: this patch was added to this series, it was split off from the
    linker tables addition due to the confusion over the code bit
    rot alternatives that are possible with linker tables.

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 Documentation/kbuild/makefiles.txt       | 36 ++++++++++++++++
 Documentation/sections/linker-tables.rst | 15 +++++++
 include/linux/tables.h                   | 71 ++++++++++++++++++++++++++++++++
 init/Kconfig                             | 22 ++++++++++
 scripts/Makefile.build                   |  7 ++--
 scripts/Makefile.lib                     | 11 +++++
 6 files changed, 159 insertions(+), 3 deletions(-)

diff --git a/Documentation/kbuild/makefiles.txt b/Documentation/kbuild/makefiles.txt
index 385a5ef41c17..01c260913f5c 100644
--- a/Documentation/kbuild/makefiles.txt
+++ b/Documentation/kbuild/makefiles.txt
@@ -1089,6 +1089,42 @@ When kbuild executes, the following steps are followed (roughly):
 	In this example, extra-y is used to list object files that
 	shall be built, but shall not be linked as part of built-in.o.
 
+    force-obj-y force-lib-y
+
+	When CONFIG_BUILD_AVOID_BITROT is enabled using these targets for your
+	kconfig symbols forces compilation of the associated objects if the
+	kconfig's symbol's dependencies are met, the objects however are only
+	linked into to the kernel if and only if the kconfig symbol was
+	enabled. If CONFIG_BUILD_AVOID_BITROT is disabled the force-obj-y and
+	force-lib-y targets are functionally equilvalent to obj-y and lib-y
+	respectively.
+
+	Using force-obj-y and force-lib-y are part of a code architecture and
+	build philosophy further enabled by linker tables, for more details
+	refer to the documention in include/linux/tables.h, refer to the
+	sections:
+
+		o The code bit-rot problem
+		o The build-all selective-link philosophy
+		o Avoiding the code bit-rot problem with linker tables
+		o Linker table module support
+
+	Modules support is expected to be enhanced in the future, so for now
+	only built-in features are supported.
+
+	Example use:
+
+		force-obj-$(CONFIG_FEATURE_FOO) += foo.o
+
+	An alternative to using force-obj-y, is to use extra-y followed by the
+	respective obj-y:
+
+		extra-y += foo.o
+		obj-$(CONFIG_FEATURE_FOO) += foo.o
+
+	Using force-obj-y and force-lib-y can be used to help annotate the
+	targets follow the 'build-all selective-link philosophy' further
+	enabled by linker tables.
 
 --- 6.7 Commands useful for building a boot image
 
diff --git a/Documentation/sections/linker-tables.rst b/Documentation/sections/linker-tables.rst
index df11c632dca7..e425c5cd36d6 100644
--- a/Documentation/sections/linker-tables.rst
+++ b/Documentation/sections/linker-tables.rst
@@ -30,6 +30,21 @@ How linker tables simplify initialization code
 .. kernel-doc:: include/linux/tables.h
    :doc: How linker tables simplify initialization code
 
+The code bit-rot problem
+------------------------
+.. kernel-doc:: include/linux/tables.h
+   :doc: The code bit-rot problem
+
+The build-all selective-link philosophy
+---------------------------------------
+.. kernel-doc:: include/linux/tables.h
+   :doc: The build-all selective-link philosophy
+
+Avoiding the code bit-rot problem with linker tables
+----------------------------------------------------
+.. kernel-doc:: include/linux/tables.h
+   :doc: Avoiding the code bit-rot problem with linker tables
+
 Using linker tables in Linux
 ==============
 
diff --git a/include/linux/tables.h b/include/linux/tables.h
index 423827eafb52..bf8fae7f9246 100644
--- a/include/linux/tables.h
+++ b/include/linux/tables.h
@@ -169,6 +169,77 @@
  */
 
 /**
+ * DOC: The code bit-rot problem
+ *
+ * Linux provides a rich array of features, enabling each feature
+ * however increases the size of the kernel and there are many
+ * features which users often want disabled. The traditional
+ * solution to this problem is for each feature to have its own
+ * Kconfig symbol, followed by a series of #ifdef statements
+ * in C code and header files, allowing the feature to be compiled
+ * only when desirable. As the variability of Linux increases build
+ * tests can and are often done with random kernel configurations,
+ * allyesconfig, and allmodconfig to help find code issues. This
+ * however doesn't catch all errors and as a consequence code that
+ * is typically not enabled often can suffer from bit-rot over time.
+ */
+
+/**
+ * DOC: The build-all selective-link philosophy
+ *
+ * A code architecture philosophy to help avoid code bit-rot consists
+ * of using Kconfig symbols for each subsystem feature, replace all #ifdefs
+ * by instead having each feature implemented it its own C file, and force
+ * compilation for all features. Only features that are enabled get linked in,
+ * the forced compilation therefore has no size impact on the final result of
+ * the kernel. The practice of having each feature implemented in its own C
+ * file is already prevalent in many subsystems, however #ifdefs are still
+ * typically required during feature initialization. For instance in::
+ *
+ *	#ifdef CONFIG_FOO
+ *	foo_init();
+ *	#endif
+ *
+ * We cannot remove the #ifdef and leave foo_init() as we'd either
+ * need to always enable the feature or add a respective #ifdef in a
+ * foo.h which makes foo_init() do nothing when ``CONFIG_FOO`` is disabled.
+ */
+
+/**
+ * DOC: Avoiding the code bit-rot problem with linker tables
+ *
+ * Linker tables can be used to further help avoid the code bit-rot problem
+ * when embracing the 'build-all selective-link philosophy' by lifting the
+ * requirement to use of #ifdefs during initialization. With linker tables
+ * initialization sequences can be aggregated into a custom ELF section at
+ * link time, during run time the table can be iterated over and each init
+ * sequence enabled can be called. A feature's init routine is only added to a
+ * table when its respective Kconfig symbols has been enabled and therefore
+ * linked in. Linker tables enable subsystems to completely do away with
+ * #ifdefs if one is comfortable in accepting all subsystem's feature's
+ * structural size implications.
+ *
+ * To further help with this the Linux build system supports two special
+ * targets, ``force-obj-y`` and ``force-lib-y``. A subsystem which wants to
+ * follow the 'build-all selective-link philosophy' can use these targets for a
+ * feature's kconfig symbol. Using these targets will always require
+ * compilation of the kconfig's objects if the kconfig symbol's dependencies
+ * are met but only link the objects into the kernel, and therefore enable the
+ * feature, if and only if the kconfig symbol has been enabled.
+ *
+ * Not all users or build systems may want to opt-in to compile all objects
+ * following the 'build-all selective-link philosophy', as such the targets
+ * ``force-obj-y`` and ``force-lib-y`` only force compilation when the kconfig
+ * symbol ``CONFIG_BUILD_AVOID_BITROT`` has been enabled. Disabling this feature
+ * makes ``force-obj-y`` and ``force-lib-y`` functionally equivalent to
+ * ``obj-y`` and ``lib-y`` respectively.
+ *
+ * Example use::
+ *
+ * 	force-obj-$(CONFIG_FEATURE_FOO) += foo.o
+ */
+
+/**
  * DOC: Linker table module support
  *
  * Modules can use linker tables, however the linker table definition
diff --git a/init/Kconfig b/init/Kconfig
index cac3f096050d..ef09e83b9196 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -53,6 +53,28 @@ config CROSS_COMPILE
 	  need to set this unless you want the configured kernel build
 	  directory to select the cross-compiler automatically.
 
+config BUILD_AVOID_BITROT
+	bool "Enable force building of force-obj-y and force-lib-y"
+	default n
+	help
+	  When enabled objects under the force-obj-y and force-lib-y targets
+	  using a Kconfig symbol will be forced to compile if the Kconfig
+	  symbol's dependencies are met but only linked into the kernel if
+	  the Kconfig symbol is enabled. If a Kconfig symbol on a force-obj-y
+	  or force-lib-y target is disabled, it will be compiled but not linked
+	  into the kernel.
+
+	  The force-obj-y and force-lib-y targets can be used by subsystems
+	  which wish to want to follow the 'build-all selective-link philosophy'
+	  documented under include/linux/tables.h.
+
+	  Say Y if you have a decent build machine and would like to help test
+	  building code for more subsystems. Say N if you do you not have a
+	  good build machine or only want to compile what you've enabled for
+	  your kernel.
+
+	  Enabling this option never increases the size of your kernel.
+
 config COMPILE_TEST
 	bool "Compile also drivers which will not load"
 	depends on !UML
diff --git a/scripts/Makefile.build b/scripts/Makefile.build
index cd9bf22bb027..cc2c7241d193 100644
--- a/scripts/Makefile.build
+++ b/scripts/Makefile.build
@@ -92,7 +92,8 @@ modorder-target := $(obj)/modules.order
 
 # We keep a list of all modules in $(MODVERDIR)
 
-__build: $(if $(KBUILD_BUILTIN),$(builtin-target) $(lib-target) $(extra-y)) \
+__build: $(if $(KBUILD_BUILTIN),$(builtin-target) $(lib-target) $(extra-y) \
+				$(force-obj-y)) \
 	 $(if $(KBUILD_MODULES),$(obj-m) $(modorder-target)) \
 	 $(subdir-ym) $(always)
 	@:
@@ -326,8 +327,8 @@ cmd_as_o_S       = $(CC) $(a_flags) -c -o $@ $<
 $(obj)/%.o: $(src)/%.S $(objtool_obj) FORCE
 	$(call if_changed_rule,as_o_S)
 
-targets += $(real-objs-y) $(real-objs-m) $(lib-y)
-targets += $(extra-y) $(MAKECMDGOALS) $(always)
+targets += $(real-objs-y) $(real-objs-m) $(lib-y) $(force-lib-y)
+targets += $(extra-y) $(force-obj-y) $(MAKECMDGOALS) $(always)
 
 # Linker scripts preprocessor (.lds.S -> .lds)
 # ---------------------------------------------------------------------------
diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
index 0a07f9014944..d1cb0cfdf1bf 100644
--- a/scripts/Makefile.lib
+++ b/scripts/Makefile.lib
@@ -12,6 +12,15 @@ export KBUILD_SUBDIR_CCFLAGS := $(KBUILD_SUBDIR_CCFLAGS) $(subdir-ccflags-y)
 # Figure out what we need to build from the various variables
 # ===================================== 
+ifeq ($(CONFIG_BUILD_AVOID_BITROT),y)
+extra-y += $(force-obj-) $(force-lib-)
+endif
+
+obj-m += $(force-obj-m)
+obj-y += $(force-obj-y)
+lib-m += $(force-lib-m)
+lib-y += $(force-lib-y)
+
 # When an object is listed to be built compiled-in and modular,
 # only build the compiled-in version
 
@@ -72,6 +81,8 @@ real-objs-m := $(foreach m, $(obj-m), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y)
 # Add subdir path
 
 extra-y		:= $(addprefix $(obj)/,$(extra-y))
+force-obj-y		:= $(addprefix $(obj)/,$(force-obj-y))
+force-obj-m		:= $(addprefix $(obj)/,$(force-obj-m))
 always		:= $(addprefix $(obj)/,$(always))
 targets		:= $(addprefix $(obj)/,$(targets))
 modorder	:= $(addprefix $(obj)/,$(modorder))
-- 
2.9.2

