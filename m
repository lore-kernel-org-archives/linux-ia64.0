From: Keith Owens <kaos@sgi.com>
Date: Mon, 02 Feb 2004 07:00:01 +0000
Subject: [patch] 0/5 2.4.25-pre7 mca.c cleanup
Message-Id: <6503.1075705201@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

mca.c has potential deadlocks on printk() for MCA and INIT records,
they are not irq safe.

There is a lot of crud in mca.c, with obsolete printing code, unused
declarations, functions and data that are global when they should be
static, functions and data that are not used or are only set to 0,
function returns that are tested but are always 0.  In addition the
code is disordered, requiring forward declarations and scattering
related functions to different parts of the file.  All of which make it
awkward to follow the code.

The following 5 patches do :-

1 Avoid deadlock when using printk() for MCA and INIT records.
2 Delete all record printing code, moved to salinfo_decode in user space.
3 Mark variables and functions static where possible.
4 Delete dead variables and functions.
5 Reorder to remove the need for forward declarations and to consolidate
  related code.

Altogether they shrink mca.c from 2420 to 1322 lines and make it much
more readable.

The only functional change is the removal of any attempt to print the
CMC/CPE/MCA/INIT record contents in the kernel.  Now we just get one
line to say that a record has been detected, except for MCA which
prints nothing at all.

