From: Masahiro Yamada <masahiroy@kernel.org>
Date: Mon, 01 Feb 2021 01:00:24 +0000
Subject: [PATCH] kbuild: remove PYTHON variable
Message-Id: <20210201010024.654526-1-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: linux-doc@vger.kernel.org, Masahiro Yamada <masahiroy@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Jonathan Corbet <corbet@lwn.net>, Michal Marek <michal.lkml@markovi.net>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Python retired in 2020, and some distributions do not provide the
'python' command any more.

As in commit 51839e29cb59 ("scripts: switch explicitly to Python 3"),
we need to use more specific 'python3' to invoke scripts even if they
are written in a way compatible with both Python 2 and 3.

This commit removes the variable 'PYTHON', and switches the existing
users to 'PYTHON3'.

BTW, PEP 394 (https://www.python.org/dev/peps/pep-0394/) is a helpful
material.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

 Documentation/Makefile             | 2 +-
 Documentation/kbuild/makefiles.rst | 2 +-
 Makefile                           | 3 +--
 arch/ia64/Makefile                 | 2 +-
 arch/ia64/scripts/unwcheck.py      | 2 +-
 scripts/jobserver-exec             | 2 +-
 6 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/Documentation/Makefile b/Documentation/Makefile
index 61a7310b49e0..9c42dde97671 100644
--- a/Documentation/Makefile
+++ b/Documentation/Makefile
@@ -75,7 +75,7 @@ quiet_cmd_sphinx = SPHINX  $@ --> file://$(abspath $(BUILDDIR)/$3/$4)
       cmd_sphinx = $(MAKE) BUILDDIR=$(abspath $(BUILDDIR)) $(build)=Documentation/userspace-api/media $2 && \
 	PYTHONDONTWRITEBYTECODE=1 \
 	BUILDDIR=$(abspath $(BUILDDIR)) SPHINX_CONF=$(abspath $(srctree)/$(src)/$5/$(SPHINX_CONF)) \
-	$(PYTHON) $(srctree)/scripts/jobserver-exec \
+	$(PYTHON3) $(srctree)/scripts/jobserver-exec \
 	$(SHELL) $(srctree)/Documentation/sphinx/parallel-wrapper.sh \
 	$(SPHINXBUILD) \
 	-b $2 \
diff --git a/Documentation/kbuild/makefiles.rst b/Documentation/kbuild/makefiles.rst
index 9f6a11881951..300d8edcb994 100644
--- a/Documentation/kbuild/makefiles.rst
+++ b/Documentation/kbuild/makefiles.rst
@@ -755,7 +755,7 @@ more details, with real examples.
 	bits on the scripts nonetheless.
 
 	Kbuild provides variables $(CONFIG_SHELL), $(AWK), $(PERL),
-	$(PYTHON) and $(PYTHON3) to refer to interpreters for the respective
+	and $(PYTHON3) to refer to interpreters for the respective
 	scripts.
 
 	Example::
diff --git a/Makefile b/Makefile
index b0e4767735dc..89217e4e68c6 100644
--- a/Makefile
+++ b/Makefile
@@ -452,7 +452,6 @@ AWK		= awk
 INSTALLKERNEL  := installkernel
 DEPMOD		= depmod
 PERL		= perl
-PYTHON		= python
 PYTHON3		= python3
 CHECK		= sparse
 BASH		= bash
@@ -508,7 +507,7 @@ CLANG_FLAGS : 
 export ARCH SRCARCH CONFIG_SHELL BASH HOSTCC KBUILD_HOSTCFLAGS CROSS_COMPILE LD CC
 export CPP AR NM STRIP OBJCOPY OBJDUMP READELF PAHOLE RESOLVE_BTFIDS LEX YACC AWK INSTALLKERNEL
-export PERL PYTHON PYTHON3 CHECK CHECKFLAGS MAKE UTS_MACHINE HOSTCXX
+export PERL PYTHON3 CHECK CHECKFLAGS MAKE UTS_MACHINE HOSTCXX
 export KGZIP KBZIP2 KLZOP LZMA LZ4 XZ ZSTD
 export KBUILD_HOSTCXXFLAGS KBUILD_HOSTLDFLAGS KBUILD_HOSTLDLIBS LDFLAGS_MODULE
 
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 703b1c4f6d12..45d5368d6a99 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -69,7 +69,7 @@ vmlinux.bin: vmlinux FORCE
 	$(call if_changed,objcopy)
 
 unwcheck: vmlinux
-	-$(Q)READELF=$(READELF) $(PYTHON) $(srctree)/arch/ia64/scripts/unwcheck.py $<
+	-$(Q)READELF=$(READELF) $(PYTHON3) $(srctree)/arch/ia64/scripts/unwcheck.py $<
 
 archclean:
 
diff --git a/arch/ia64/scripts/unwcheck.py b/arch/ia64/scripts/unwcheck.py
index bfd1b671e35f..9581742f0db2 100644
--- a/arch/ia64/scripts/unwcheck.py
+++ b/arch/ia64/scripts/unwcheck.py
@@ -1,4 +1,4 @@
-#!/usr/bin/env python
+#!/usr/bin/env python3
 # SPDX-License-Identifier: GPL-2.0
 #
 # Usage: unwcheck.py FILE
diff --git a/scripts/jobserver-exec b/scripts/jobserver-exec
index 0fdb31a790a8..48d141e3ec56 100755
--- a/scripts/jobserver-exec
+++ b/scripts/jobserver-exec
@@ -1,4 +1,4 @@
-#!/usr/bin/env python
+#!/usr/bin/env python3
 # SPDX-License-Identifier: GPL-2.0+
 #
 # This determines how many parallel tasks "make" is expecting, as it is
-- 
2.27.0
