From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 22 May 2003 01:33:16 +0000
Subject: [Linux-ia64] new ia64 patch (relative to 2.5.69)
Message-Id: <marc-linux-ia64-105590723705980@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

An updated 2.5.69 patch is now available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/

in linux-2.5.69-ia64-030521.diff.gz.

Warning: I pushed a patch of the same name earlier today, just to find
that core-dumps were broken.  I fixed that now and updated the patch.
If you don't have the latest version, the attached patch will be
missing.

This kernel should be fairly stable (at least it has been for me).

I'm planning to apply a patch next a patch by Rohit Seth and some
other folks at Intel.  This patch restructures struct pt_regs and
optimizes the syscall path not to save/restore scratch registers.
Most definitely non-trivial stuff and will need a lot of testing.  But
if things break unexpectedly, we can easily fall back to the current
snapshot.

	--david

diff -Nru a/arch/ia64/kernel/unwind.c b/arch/ia64/kernel/unwind.c
--- a/arch/ia64/kernel/unwind.c	Wed May 21 18:24:17 2003
+++ b/arch/ia64/kernel/unwind.c	Wed May 21 18:24:17 2003
@@ -239,7 +239,10 @@
 	if (!info->pt) {
 		/* This should not happen with valid unwind info.  */
 		UNW_DPRINT(0, "unwind.%s: bad unwind info: resetting info->pt\n", __FUNCTION__);
-		info->pt = info->sp - 16;
+		if (info->flags & UNW_FLAG_INTERRUPT_FRAME)
+			info->pt = (unsigned long) ((struct pt_regs *) info->psp - 1);
+		else
+			info->pt = info->sp - 16;
 	}
 	UNW_DPRINT(3, "unwind.%s: sp 0x%lx pt 0x%lx\n", __FUNCTION__, info->sp, info->pt);
 	return (struct pt_regs *) info->pt;

