From: Keith Owens <kaos@sgi.com>
Date: Fri, 22 Oct 2004 04:25:55 +0000
Subject: Converting ia64 kernel unwinder to lock free code
Message-Id: <5907.1098419155@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

MCA and INIT events are not irq safe, they can interrupt the kernel at
any point, including with spin_lock_irqsave() set.  We currently call
the ia64 kernel unwinder from MCA and INIT handlers, which has the
potential to deadlock or to return invalid results.  I want to convert
the kernel unwinder to be lock free, so it can be called from any
state.  That means no locks, and no calls to kernel sevices that might
deadlock, including printk and kmalloc.

Before I start on this task, are there any other plans for the kernel
unwinder code?  In the past davidm has hinted at replacing it with
libunwind.

