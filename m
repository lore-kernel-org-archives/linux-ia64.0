From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 07 Dec 2006 00:40:03 +0000
Subject: Re: [PATCH] CPEI gets warning at kernel/irq/migration.c:27/move_masked_irq()
Message-Id: <457762E3.2010909@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4575212A.3020902@jp.fujitsu.com>	 <20061205221913.1ef416f9.akpm@osdl.org> <1165386976.3233.428.camel@laptopd505.fenrus.org>
In-Reply-To: <1165386976.3233.428.camel@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arjan van de Ven <arjan@infradead.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>

Arjan van de Ven wrote:
>> It'd be nice if we could just teach the userspace balancer to not try to
>> move perpcu IRQs?
>>
>> otoh, the patch is super-cheap.   Arjan?
> 
> I can fix irqbalance no problem, however I like the kernel approach as
> well, since it's not just irqbalance that moves irqs, sysadmins tend to
> do it as well....  so how about both?

Thanks for positive comments.

> One thing we probably should do, and that would help irqbalance
> immensely, is to export a bitmask for which cpus an interrupt CAN go to,
> next to where the current binding interface is. I'll check into that
> 
> Hidetoshi: would it be possible to send me a /proc/interrupts file of
> that machine?

Here you are.
This machine is not special. I guess all ia64 machine will show
few or more but almost same lines. CPEI is #30.

$ cat /proc/interrupts
           CPU0       CPU1
 28:          0          0          LSAPIC  cpe_poll
 29:          0          0          LSAPIC  cmc_poll
 30:          0          0  IO-SAPIC-level  cpe_hndlr
 31:          0          0          LSAPIC  cmc_hndlr
 34:       4643    1881067   IO-SAPIC-edge  ide0
 39:          0          0  IO-SAPIC-level  acpi
 45:        148        560   IO-SAPIC-edge  serial
 48:          0          0  IO-SAPIC-level  uhci_hcd
 49:          0          0  IO-SAPIC-level  uhci_hcd
 50:          0          0  IO-SAPIC-level  ehci_hcd
 51:      21131    1257790  IO-SAPIC-level  eth0
 53:      21778     458314  IO-SAPIC-level  ioc0
 54:          0         44  IO-SAPIC-level  ioc1
232:          0          0          LSAPIC  mca_rdzv
238:          0          0          LSAPIC  perfmon
239:  214832233  214832003          LSAPIC  timer
240:          0          0          LSAPIC  mca_wkup
254:     209193        611          LSAPIC  IPI
ERR:          0

Thanks,
H.Seto

