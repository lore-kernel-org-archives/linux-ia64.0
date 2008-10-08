From: Simon Horman <horms@verge.net.au>
Date: Wed, 08 Oct 2008 06:49:41 +0000
Subject: [patch] ia64: Order of operations bug in PT_LOAD segment reader
Message-Id: <20081008064940.GA11893@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, kexec@lists.infradead.org
Cc: Jay Lan <jlan@sgi.com>, Bernhard Walle <bwalle@suse.de>, "Luck,
	Tony" <tony.luck@intel.com>

This bug was discovered by Jay Lan and he also proposed this fix, however
thee is some discussion about what if any related changes should be made at
the same time.

The bug comes about because the break statment was never executed because
the if clause would bever be true because the if clause will never be true
because &  has higher precedence than !=.

My position on this is that with the if logic fixed, as per this patch, the
break statment and the rest of the while() loop makes sense and should work
as intended.

As I understand it, Jay's position is that the code should be simplified,
after all it never worked as intended.

There is a related kernel bug that lead Jay to discover this problem.
The kernel bug has been resolved by Tony Luck and was
included in Linus's tree between 2.6.27-rc8 and 2.6.27-rc9 as
"[IA64] Put the space for cpu0 per-cpu area into .data section".

Now that the kernel bug is out of the way, I am providing this patch to
continue discussion on what to do on the kexec-tools side of things.  I do
not intend to apply this patch until there is some conclusion in the
discussion between Jay and myself.

Cc: Jay Lan <jlan@sgi.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

Index: kexec-tools/kexec/arch/ia64/crashdump-ia64.c
=================================--- kexec-tools.orig/kexec/arch/ia64/crashdump-ia64.c	2008-10-08 17:31:42.000000000 +1100
+++ kexec-tools/kexec/arch/ia64/crashdump-ia64.c	2008-10-08 17:32:08.000000000 +1100
@@ -91,7 +91,7 @@ static void add_loaded_segments_info(str
 	                if (phdr->p_type != PT_LOAD)
 	                        break;
 			if (loaded_segments[loaded_segments_num].end !-				phdr->p_paddr & ~(ELF_PAGE_SIZE-1))
+				(phdr->p_paddr & ~(ELF_PAGE_SIZE-1)))
 				break;
 			loaded_segments[loaded_segments_num].end + 				(phdr->p_memsz + ELF_PAGE_SIZE - 1) &

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

