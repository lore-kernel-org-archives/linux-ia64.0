From: John Kohl <jtk@rational.com>
Date: Thu, 01 Mar 2001 16:29:16 +0000
Subject: [Linux-ia64] more problems with 2001-02-28 kit (can't build uniprocessor)
Message-Id: <marc-linux-ia64-105590693005227@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I ran into more build problems with the 2001-02-28 patch kit.  I can't
build a non-SMP kernel.

One bug I can fix, the other I'm not sure what the right thing to do is.

irq.c:458:28: too many arguments in invocation of macro "local_irq_count"
irq.c:474:27: too many arguments in invocation of macro "local_irq_count"
irq.c: In function `handle_IRQ_event':
irq.c:458: `local_irq_count' undeclared (first use in this function)
irq.c:458: (Each undeclared identifier is reported only once
irq.c:458: for each function it appears in.)

This is fixable by the attached patch.

irq_ia64.c: In function `init_IRQ':
irq_ia64.c:158: `ipi_irqaction' undeclared (first use in this function)
irq_ia64.c:158: (Each undeclared identifier is reported only once
irq_ia64.c:158: for each function it appears in.)

This, I'm not sure what to do--should IPI-related stuff even be compiled when
CONFIG_SMP is not set?

--- hardirq.h.~1~	Thu Mar  1 09:47:38 2001
+++ include/asm-ia64/hardirq.h	Thu Mar  1 11:25:27 2001
@@ -41,8 +41,8 @@
 # define local_hardirq_trylock()	(local_irq_count() = 0)
 # define local_hardirq_endlock()	do { } while (0)
 
-# define local_irq_enter(irq)		(local_irq_count(cpu)++)
-# define local_irq_exit(irq)		(local_irq_count(cpu)--)
+# define local_irq_enter(irq)		(local_irq_count()++)
+# define local_irq_exit(irq)		(local_irq_count()--)
 
 # define synchronize_irq()		barrier()
 #else

-- 
=John Kohl <jtk@rational.com>, Senior Staff Software Engineer
Rational Software, Configuration Management Business Unit
Mark your calendars!  Rational User Conference 2001, July 22-26, 2001
in beautiful Denver, Colorado

