From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 17 Mar 2004 12:48:00 +0000
Subject: [PATCH] current  ( was  RE: cat /proc/acpi/events bad for your system's health!)
Message-Id: <3ACA40606221794F80A5670F0AF15F8401CBB762@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> The main difference with 2.4 is signal_pending. From ACPI log, I also
> noticed that
> the thread waiting on acpi_bus_event_queue didn't resume proberly,
> because there
> is no exit message of acpi_bus_receive_event in ACPI log  as 
> expected if
> you turn on
> full debug flag of acpi.

After comparing the disassembly code of acpi_bus_receive_event() , I
find the following difference
introduced by my workaround:

155c155
<     12d0:     00 00 00 1a b8 11       [MII]       st8.rel [r13]=r0
---
>     12d0:     00 40 00 1a b8 15       [MII]       st8.rel [r13]=r0,8


Perhaps, gcc did something wrong with set_current_state(TASK_RUNNING).
Because r13 intend for pointer to the current task.

The following is my patch, which can fix this issue.

--Luming

diff -Bru 2.6.new/include/asm-ia64/gcc_intrin.h
patched/include/asm-ia64/gcc_intrin.h
--- 2.6.new/include/asm-ia64/gcc_intrin.h	2004-03-17
11:57:34.000000000 +0800
+++ patched/include/asm-ia64/gcc_intrin.h	2004-03-17
20:39:44.000000000 +0800
@@ -67,10 +67,7 @@
 		asm volatile ("mov %0=psr" : "=r"(ia64_intri_res));
\
 		break;
\
 	case _IA64_REG_TP:	/* for current() */
\
-		{
\
-			register __u64 ia64_r13 asm ("r13");
\
-			ia64_intri_res = ia64_r13;
\
-		}
\
+		asm volatile ("mov %0=r13" : "=r"(ia64_intri_res));
\
 		break;
\
 	case _IA64_REG_AR_KR0 ... _IA64_REG_AR_EC:
\
 		asm volatile ("mov %0=ar%1" : "=r" (ia64_intri_res)
\
