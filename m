From: Matt Domsch <Matt_Domsch@Dell.com>
Date: Thu, 05 Dec 2002 22:50:46 +0000
Subject: RE: [Linux-ia64] 2.5.50+ patch for the impatient...
Message-Id: <marc-linux-ia64-105590709805508@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805503@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805503@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Something must have gone wrong with applying the ia64 patch.

Yep.  Fixed here, thanks.

Without CONFIG_SMP, cpu_possible() isn't defined.  I think it needs this:

=== include/asm-ia64/smp.h 1.8 vs edited ==--- 1.8/include/asm-ia64/smp.h	Mon Aug 12 06:06:34 2002
+++ edited/include/asm-ia64/smp.h	Thu Dec  5 16:49:20 2002
@@ -138,6 +138,8 @@
 extern void smp_send_reschedule (int cpu);
 extern void smp_send_reschedule_all (void);
 
+#else /* !CONFIG_SMP */
+#define cpu_possible(cpu)	(!cpu)
 
 #endif /* CONFIG_SMP */
 #endif /* _ASM_IA64_SMP_H */


Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer, Architect
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com



