From: Sam Ravnborg <sam@ravnborg.org>
Date: Wed, 14 May 2003 17:48:46 +0000
Subject: Re: [Linux-ia64] Parallel make
Message-Id: <marc-linux-ia64-105590723705803@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705774@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705774@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 14, 2003 at 01:38:23PM +1000, Ian Wienand wrote:
> When I try a parallel make, make seems to get it's dependencies out of
> order.  

Could you try the following patch.

It does:
1) Remove superflous all: target, covered by the main Makefile
2) .PHONY shall only list non-file targets
3) Use make $@, $< where appropriate
4) For the offset file do not duplicate dependencies from main Makefile

	Sam

=== arch/ia64/Makefile 1.42 vs edited ==--- 1.42/arch/ia64/Makefile	Wed Mar 26 17:30:43 2003
+++ edited/arch/ia64/Makefile	Wed May 14 19:46:03 2003
@@ -60,17 +60,15 @@
 boot := arch/ia64/boot
 tools := arch/ia64/tools
 
-.PHONY: boot compressed include/asm-ia64/offsets.h
-
-all: prepare vmlinux
+.PHONY: boot compressed check
 
 compressed: vmlinux.gz
 
 vmlinux.gz: vmlinux
-	$(Q)$(MAKE) $(build)=$(boot) vmlinux.gz
+	$(Q)$(MAKE) $(build)=$(boot) $@
 
 check: vmlinux
-	arch/ia64/scripts/unwcheck.sh vmlinux
+	arch/ia64/scripts/unwcheck.sh $<
 
 archclean:
 	$(Q)$(MAKE) $(clean)=$(boot)
@@ -83,7 +81,7 @@
 boot:	lib/lib.a vmlinux
 	$(Q)$(MAKE) $(build)=$(boot) $@
 
-include/asm-ia64/offsets.h: include/asm include/linux/version.h include/config/MARKER
+include/asm-ia64/offsets.h:
 	$(Q)$(MAKE) $(build)=$(tools) $@
 
 define archhelp

