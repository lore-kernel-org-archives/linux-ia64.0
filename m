From: Keith Owens <kaos@sgi.com>
Date: Thu, 27 Nov 2003 00:12:18 +0000
Subject: Unwind bug on out of line code called from leaf functions
Message-Id: <marc-linux-ia64-106989195923088@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64_spinlock_contention_pre3_4 has

        .save ar.pfs, r0        // this code effectively has a zero frame size

If ia64_spinlock_contention_pre3_4 is called from a leaf function,
takes an interrupt and you unwind through the contenion code, the
unwind steps are

  pt_regs.cr_ifs
  ia64_spinlock_contention_pre3_4, ar.pfs = 0
  leaf function, no unwind data, ar.pfs is unchanged and stays at 0!

There is no problem when ia64_spinlock_contention_pre3_4 is called from
a non-leaf function.  The non-leaf function has unwind data which
resets ar.pfs, the problem only occurs when the caller of the out of
line code has no unwind data and is using .

I have hacked kdb to recognise that it is unwinding the caller of the
out of line code and force ar.pfs to pt_regs.ar_pfs.  That is the
correct value for leaf functions.  The unwind data for non-leaf
functions will override this default value of ar.pfs.

I know that gcc 3.4 overcomes this problem by saving ar.pfs in leaf
functions and using br.call.  However we need a fix for gcc in the
current distributions, even with gcc 3.4 we may wish to use out of line
code that does not save ar.pfs in the future.

We need a generic fix for unwinding through out of line code called
from leaf functions and not using br.call.  The obvious solution is to
flag all out of line code with an unwind abi field and have the common
unwind code reset ar.pfs.  Can I use .unwabi 3, 'o' for out of line?

