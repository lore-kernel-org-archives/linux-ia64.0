From: Keith Owens <kaos@sgi.com>
Date: Thu, 05 Feb 2004 02:26:43 +0000
Subject: [patch] 0/6 2.6.2-rc2 mca.c cleanup
Message-Id: <4481.1075948003@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Port the ia64 mca.c clean up patches from 2.4.25-pre8 to 2.6.2-rc2.

The following 6 patches do :-

1 Avoid deadlock when using printk() for MCA and INIT records.
2 Delete all record printing code, moved to salinfo_decode in user space.
3 Mark variables and functions static where possible.
4 Delete dead variables and functions.
5 Reorder to remove the need for forward declarations and to consolidate
  related code.
6 Bjorn's printk cleanup.

Altogether they shrink mca.c from 2432 to 1339 lines and make it much
more readable.

The only functional change is the removal of any attempt to print the
CMC/CPE/MCA/INIT record contents in the kernel plus the addition of an
info printk to ia64_mca_check_errors(), to match 2.4.  Now we just get
one line to say that a record has been detected, except for MCA which
prints nothing at all.

