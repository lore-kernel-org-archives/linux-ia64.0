From: Jim Wilson <wilson@tuliptree.org>
Date: Sun, 06 Apr 2003 15:49:09 +0000
Subject: [Linux-ia64] dependency violation table problem
Message-Id: <marc-linux-ia64-105590723705424@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Gas fails for this simple testcase.
        .auto
        ldfs f8 = [r32]
        stfd [r33] = f8
It should insert a stop bit between the load and store, but does not.

This appears to be a bug in the Intel dependency violation (DV) tables.

In the Intel Itanium Architecture Software Developer's Manual (IIASDM),
vol 3, revision 2.1, page 342, table 5-2, says that there is a RAW DV
for a FR% register if fr-writers is followed by fr-readers.

fr-readers is defined on page 352, table 5-5.  It includes arith
operations (e.g. add), non-arith operations (e.g. and), and a few other
things, but it does not include stf.  This looks like a bug in the Intel
documentation.

I believe this should be fixed by adding IC:mem-writers-fp to
fr-readers.  This makes gas work as expected.

As long as I'm reporting documentation problems, there is another less
important one I've noticed.  In the X unit instruction encodings, IIASDM
vol 3 rev 2.1 page 332 table 4-73, it mentions nop.m and hint.m.  These
should be nop.x and hint.x.

I'm off on a 4000 km international move, so I will be offline for a week
or two.

Jim





