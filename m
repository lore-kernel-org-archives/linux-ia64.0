From: Martin Pool <mbp@samba.org>
Date: Fri, 02 May 2003 06:43:37 +0000
Subject: [Linux-ia64] avoid exceptions in copy_from_user?
Message-Id: <marc-linux-ia64-105590723705628@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is probably a flawed idea but I was just curious: could the
kernel use speculative loads to avoid taking exceptions when a
copy_from_user or related function faults?  (Something like the
routine below.)

I thought that if the chk.s instructions could fit into otherwise
unused slots, then failing copies would avoid needing to take an
interrupt and search the fixup table, and could instead branch
directly to the code to clean up and return.

I suspect the answer is that it's not worthwhile, because if the copy
fails then the kernel is about to go and do something expensive like
paging or killing the task, and so a little more overhead is not
important, and anyhow adding instructions to the non-failing case is
undesirable.


// int readit(int *a)
// return the contents of a, or -1 if a is not a valid pointer

.text
	.align 16
	.global readit#
	.proc readit#
readit:
	.prologue
	// one input, no locals
	alloc r2 = ar.pfs, 1, 0, 0, 0
	
	.body

	// Try to read the thing
	ld8.s ret0 = [in0]
	;;

	// Did we break?
	chk.s ret0, .recovery
	
	// Return
	br.ret.sptk.many b0

.recovery:	
	mov	ret0 = -1
	;; 
	br.ret.sptk.many b0

	.end readit#


-- 
Martin 




