From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Fri, 02 Mar 2018 04:31:51 +0000
Subject: [PATCH v2 01/11] kbuild: define PYTHON2 and PYTHON3 variables instead of PYTHON
Message-Id: <1519965121-12017-2-git-send-email-yamada.masahiro@socionext.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1519965121-12017-1-git-send-email-yamada.masahiro@socionext.com>
In-Reply-To: <1519965121-12017-1-git-send-email-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: Sam Ravnborg <sam@ravnborg.org>, Michal Marek <michal.lkml@markovi.net>, Ulf Magnusson <ulfalizer@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>

The variable 'PYTHON' allows users to specify a proper executable
name in case the default 'python' does not work.  However, this does
not address the case where both Python 2 and Python 3 scripts are
used in one source tree.

PEP 394 (https://www.python.org/dev/peps/pep-0394/) provides a
convention for Python scripts portability.  Here is a quotation:

  In order to tolerate differences across platforms, all new code
  that needs to invoke the Python interpreter should not specify
  'python', but rather should specify either 'python2' or 'python3'.
  This distinction should be made in shebangs, when invoking from a
  shell script, when invoking via the system() call, or when invoking
  in any other context.

arch/ia64/scripts/unwcheck.py is apparently written in Python 2, so
it should be invoked by 'python2'.

It is legitimate to use 'python' for scripts compatible with both
Python 2 and Python 3, but this is rare (at least I do not see the
case in kernel tree).  You do not need to make efforts to write your
scripts in that way.  Anyway, Python 2 will retire in 2020.

This commit is needed for new scripts written in Python 3.

For the backward compatibility for ia64, if 'PYTHON' is specified,
it is propagated to 'PYTHON2'.

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

Changes in v2:
  - Add backward compatibility for PYTHON

 Makefile           | 5 +++--
 arch/ia64/Makefile | 2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/Makefile b/Makefile
index 4fb97e9..ea23d9b 100644
--- a/Makefile
+++ b/Makefile
@@ -393,7 +393,8 @@ GENKSYMS	= scripts/genksyms/genksyms
 INSTALLKERNEL  := installkernel
 DEPMOD		= /sbin/depmod
 PERL		= perl
-PYTHON		= python
+PYTHON2	       := $(if $(PYTHON), $(PYTHON), python2)
+PYTHON3	       := python3
 CHECK		= sparse
 
 CHECKFLAGS     := -D__linux__ -Dlinux -D__STDC__ -Dunix -D__unix__ \
@@ -439,7 +440,7 @@ GCC_PLUGINS_CFLAGS : 
 export ARCH SRCARCH CONFIG_SHELL HOSTCC HOSTCFLAGS CROSS_COMPILE AS LD CC
 export CPP AR NM STRIP OBJCOPY OBJDUMP HOSTLDFLAGS HOST_LOADLIBES
-export MAKE LEX YACC AWK GENKSYMS INSTALLKERNEL PERL PYTHON UTS_MACHINE
+export MAKE LEX YACC AWK GENKSYMS INSTALLKERNEL PERL PYTHON2 PYTHON3 UTS_MACHINE
 export HOSTCXX HOSTCXXFLAGS LDFLAGS_MODULE CHECK CHECKFLAGS
 
 export KBUILD_CPPFLAGS NOSTDINC_FLAGS LINUXINCLUDE OBJCOPYFLAGS LDFLAGS
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 2dd7f51..862a2ba 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -75,7 +75,7 @@ vmlinux.gz: vmlinux
 	$(Q)$(MAKE) $(build)=$(boot) $@
 
 unwcheck: vmlinux
-	-$(Q)READELF=$(READELF) $(PYTHON) $(srctree)/arch/ia64/scripts/unwcheck.py $<
+	-$(Q)READELF=$(READELF) $(PYTHON2) $(srctree)/arch/ia64/scripts/unwcheck.py $<
 
 archclean:
 	$(Q)$(MAKE) $(clean)=$(boot)
-- 
2.7.4

