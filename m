From: Masahiro Yamada <yamada.m@jp.panasonic.com>
Date: Fri, 18 Jul 2014 04:40:11 +0000
Subject: [PATCH] kbuild: allow to override Python command name
Message-Id: <1405658411-27346-1-git-send-email-yamada.m@jp.panasonic.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: Masahiro Yamada <yamada.m@jp.panasonic.com>, linux-ia64@vger.kernel.org, Michal Marek <mmarek@suse.cz>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-kernel@vger.kernel.org

The specification of Python 3 is largely different from that of
Python 2.

For example, arch/ia64/scripts/unwcheck.py seems to be written
in Python 2, not compatible with Python 3.

It is not a good idea to invoke python scripts with the hard-coded
command name 'python'. The command 'python' could possibly be
Python 3 on some systems.
For that case, it is reasonable to allow to override the command name
by giving 'PYTHON=python2' from the command line.

The 'python' in arch/ia64/Makefile should be replaced with '$(PYTHON)'.

Signed-off-by: Masahiro Yamada <yamada.m@jp.panasonic.com>
Cc: linux-ia64@vger.kernel.org
---

 Makefile           | 3 ++-
 arch/ia64/Makefile | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/Makefile b/Makefile
index f3c543d..7f5f301 100644
--- a/Makefile
+++ b/Makefile
@@ -372,6 +372,7 @@ GENKSYMS	= scripts/genksyms/genksyms
 INSTALLKERNEL  := installkernel
 DEPMOD		= /sbin/depmod
 PERL		= perl
+PYTHON		= python
 CHECK		= sparse
 
 CHECKFLAGS     := -D__linux__ -Dlinux -D__STDC__ -Dunix -D__unix__ \
@@ -422,7 +423,7 @@ KERNELVERSION = $(VERSION)$(if $(PATCHLEVEL),.$(PATCHLEVEL)$(if $(SUBLEVEL),.$(S
 export VERSION PATCHLEVEL SUBLEVEL KERNELRELEASE KERNELVERSION
 export ARCH SRCARCH CONFIG_SHELL HOSTCC HOSTCFLAGS CROSS_COMPILE AS LD CC
 export CPP AR NM STRIP OBJCOPY OBJDUMP
-export MAKE AWK GENKSYMS INSTALLKERNEL PERL UTS_MACHINE
+export MAKE AWK GENKSYMS INSTALLKERNEL PERL PYTHON UTS_MACHINE
 export HOSTCXX HOSTCXXFLAGS LDFLAGS_MODULE CHECK CHECKFLAGS
 
 export KBUILD_CPPFLAGS NOSTDINC_FLAGS LINUXINCLUDE OBJCOPYFLAGS LDFLAGS
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index f37238f..5441b14 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -76,7 +76,7 @@ vmlinux.gz: vmlinux
 	$(Q)$(MAKE) $(build)=$(boot) $@
 
 unwcheck: vmlinux
-	-$(Q)READELF=$(READELF) python $(srctree)/arch/ia64/scripts/unwcheck.py $<
+	-$(Q)READELF=$(READELF) $(PYTHON) $(srctree)/arch/ia64/scripts/unwcheck.py $<
 
 archclean:
 	$(Q)$(MAKE) $(clean)=$(boot)
-- 
1.9.1

