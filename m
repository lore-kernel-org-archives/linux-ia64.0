From: alext@fc.hp.com (Alex Tsariounov)
Date: Fri, 04 Jun 2004 18:49:10 +0000
Subject: small syntax patch to entry.S
Message-Id: <20040604184909.GB2294@fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello, David,

I looked on the latest bitkeeper ia64 tree (well, at least what I
thought was the latest...) and this one still seems to be there.
It doesn't seem to bother the assembler, but it gives my syntax
colorizer the chills.

Thanks,
Alex


diff -Nru -X dontdiff linux-2.6.6/arch/ia64/kernel/entry.S linux-2.6.6.fix/arch/ia64/kernel/entry.S
--- linux-2.6.6/arch/ia64/kernel/entry.S	2004-06-04 12:32:57.000000000 -0600
+++ linux-2.6.6.fix/arch/ia64/kernel/entry.S	2004-06-04 12:34:09.000000000 -0600
@@ -21,7 +21,7 @@
  * Jonathan Nicklin	<nicklin@missioncriticallinux.com>
  * Patrick O'Rourke	<orourke@missioncriticallinux.com>
  * 11/07/2000
- /
+ */
 /*
  * Global (preserved) predicate usage on syscall entry/exit path:
  *
