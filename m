From: John Kohl <jtk@rational.com>
Date: Fri, 15 Dec 2000 16:32:48 +0000
Subject: [Linux-ia64] test11, test12 kernel vs. big sur: Unexpected irq vector
Message-Id: <marc-linux-ia64-105590678205850@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I tried booting a kernel built from the latest test12 patch kit on one
of our development systems (big sur, A stepping).  It
starts up, prints out a few messages, then loops forever printing
       Unexpected irq vector 0x0 on CPU 0!
This comes from arch/ia64/kernel/irq.c.

We had the same problems with the test11 kernels.  Any suggestions on
how to debug and/or remedy this?

-- 
=John Kohl <jtk@rational.com>, Software Engineer
Rational Software, Configuration Management Business Unit
Mark your calendars!  Rational User Conference 2001, July 22-26, 2001
in beautiful Denver, Colorado

