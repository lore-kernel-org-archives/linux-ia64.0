From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 07 Dec 2002 04:57:10 +0000
Subject: RE: [Linux-ia64] 2.5.50+ patch for the impatient...
Message-Id: <marc-linux-ia64-105590709805513@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805503@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805503@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 5 Dec 2002 16:50:46 -0600 (CST), Matt Domsch <Matt_Domsch@Dell.com> said:

  >> Something must have gone wrong with applying the ia64 patch.
  Matt> Yep.  Fixed here, thanks.

  Matt> Without CONFIG_SMP, cpu_possible() isn't defined.  I think it
  Matt> needs this:

  Matt> === include/asm-ia64/smp.h 1.8 vs edited === ---
  Matt> 1.8/include/asm-ia64/smp.h Mon Aug 12 06:06:34 2002 +++
  Matt> edited/include/asm-ia64/smp.h Thu Dec 5 16:49:20 2002 @@
  Matt> -138,6 +138,8 @@ extern void smp_send_reschedule (int cpu);
  Matt> extern void smp_send_reschedule_all (void);
 
  Matt> +#else /* !CONFIG_SMP */ +#define cpu_possible(cpu) (!cpu)
 
  Matt>  #endif /* CONFIG_SMP */ #endif /* _ASM_IA64_SMP_H */

Actually, I think this needs to be defined in linux/smp.h.  This
appears to be fixed already in Linus's bk tree
(see http://linux.bkbits.net:8080/linux-2.5/diffs/include/linux/smp.h@1.18).

	--david

