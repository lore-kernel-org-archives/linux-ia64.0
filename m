From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 Jun 2002 01:40:09 +0000
Subject: [Linux-ia64] IMPORTANT: memory corruption bug (with prelimenary fix)
Message-Id: <marc-linux-ia64-105590701905693@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is a longstanding bug in the ia64 linux kernel which, under just
the right circumstances, can cause virtual memory corruption.  The
exact conditions to trigger this are a bit complicated, but basically,
the bug doesn't trigger unless an munmap() occurs near the end of the
per-region mappable address space and that region contains some other
mappings.  In 2.4.18, triggering this bug has become slightly easier
because we moved the stack down from region 4 to region 3 (the stack
is at the end of the mappable space and the low part of region 3 is
occupied by the data segment, which is the likely victim of a memory
corruption triggered by someone doing mapping games near the stack
area).

The patch below is a two-liner which _should_ fix the problem.  I plan
to verify the fix some more for correctness, but it's definitely safe
and fixes the one scenario that is known to trigger the bug.

Jack, I'm wondering whether this is related to the pthread problem you
reported earlier?  Can you try this patch?

Thanks to Steve Goldman for bringing this problem to my attention and
for providing a test case.

	--david

--- mm/mmap.c~	Wed Jun 19 14:21:37 2002
+++ mm/mmap.c	Wed Jun 19 17:19:53 2002
@@ -883,6 +883,8 @@
 		break;
 	}
 no_mmaps:
+	if (last < first)
+		return;
 	/*
 	 * If the PGD bits are not consecutive in the virtual address, the
 	 * old method of shifting the VA >> by PGDIR_SHIFT doesn't work.

