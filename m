From: akpm@linux-foundation.org
Date: Tue, 13 Nov 2007 09:13:22 +0000
Subject: [patch 1/1] ia64: don't assume that unwcheck.py is executable
Message-Id: <200711130920.lAD9KJJ1003496@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

Don't assume that this file has execute permissions.  For example, patch(1)
loses that information.

Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/Makefile |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN arch/ia64/Makefile~ia64-dont-assume-that-unwcheckpy-is-executable arch/ia64/Makefile
--- a/arch/ia64/Makefile~ia64-dont-assume-that-unwcheckpy-is-executable
+++ a/arch/ia64/Makefile
@@ -77,7 +77,7 @@ vmlinux.gz: vmlinux
 	$(Q)$(MAKE) $(build)=$(boot) $@
 
 unwcheck: vmlinux
-	-$(Q)READELF=$(READELF) $(srctree)/arch/ia64/scripts/unwcheck.py $<
+	-$(Q)READELF=$(READELF) $(CONFIG_SHELL) $(srctree)/arch/ia64/scripts/unwcheck.py $<
 
 archclean:
 	$(Q)$(MAKE) $(clean)=$(boot)
_
