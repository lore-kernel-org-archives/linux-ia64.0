From: Francois Wellenreiter <Francois.Wellenreiter@Ext.Bull.Net>
Date: Tue, 17 Aug 2004 12:50:46 +0000
Subject: writing to "/proc/irq/xxxx/smp_affinity" produces a kernel crash
Message-Id: <4121FF26.70102@Ext.Bull.Net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



				Dear all,

	Apparently a little bug was introduced in 2.6.7 kernel dealing with IRQ
redirection managemant via proc filesystem.
The behavior is quite simple, just type :

echo "r 00000001" > /proc/irq/{xy}/smp_affinity

where {xy} is a valid irq, and your kernel will crash.

The bug is located in the file arch/ia64/kernel/irq.c , function 
irq_affinity_write_proc,
at the following line we set a value called irq :
__________________

         if (copy_from_user(rbuf, buffer, rlen))
                 return -EFAULT;
         rbuf[rlen] = 0;
         prelen = 0;
         if (tolower(*rbuf) = 'r') {
                 prelen = strspn(rbuf, "Rr ");
                 irq |= IA64_IRQ_REDIRECTED; <----- IA64_IRQ_REDIRECTED
= 1<31 !!!!!
         }

__________________

and later it is written :
__________________

         spin_lock_irqsave(&desc->lock, flags);
         pending_irq_cpumask[irq] = new_value; <----- code generating a 
fatal page fault
         spin_unlock_irqrestore(&desc->lock, flags);
__________________


reading this code, a trouble clearly exists around the irq notion.
The "irq" corresponding to irq number programmed in IOSAPIC
(taking into account the IA64_IRQ_REDIRECTED bit) is mixed with the
the irq index in the irq_affinity table.

Best regards,


				Francois WELLENREITER


