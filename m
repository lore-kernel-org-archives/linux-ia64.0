From: Uros Prestor <uros@turbolinux.com>
Date: Tue, 22 Aug 2000 17:52:04 +0000
Subject: [Linux-ia64] [Fwd: [ia64-dist] Problems with interrupts on 50 Mhz PCI slots.]
Message-Id: <marc-linux-ia64-105590678205374@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am forwarding this question to linux-ia64 in case somebody there has an
explanation.

Nelson Escobar wrote:

> I am running TurboLinux 0714 with the kernel updated to test 4 on a four
> CPU Lion system (A3 processors).  The bios is build 55.
>
> I was trying to get a high speed networking card which worked just fine on
> the 25 Mhz slots to work on one of the 50 Mhz slots.  This is when things
> started to get a little weird.
>
> First, any cards put in those slots ( the pci slots on buses 2-6 ) were
> all assigned irq 11.  There are also a few PCI Hot-plug controllers also
> on IRQ 11.
>
> Looking at /proc/interrupts revealed some more weirdness:
>
>  11:          0            none  myri/gm
>  40:          0  IO-SAPIC-level  perfmon
>  48:       2395  IO-SAPIC-level  qla1280
>  51:      17177  IO-SAPIC-level  eth0
>  64:          6   IO-SAPIC-edge  ide0
>  65:          4   IO-SAPIC-edge  ide1
>  80:          5   IO-SAPIC-edge  keyboard
>  89:        189   IO-SAPIC-edge  PS/2 Mouse
> 239:     705213           SAPIC  timer
>
> The myri/gm is the driver for the card i am interested in.
>
> First I noticed that there were 0 interrupts on IRQ 11, which is false
> since i know for a fact that the card generated an interrupt.  Then I
> noticed the 'none' where I expected to see 'IO-SAPIC-level'.
>
> So has anyone seen this before?  Is this a known problem?
>
> Nelson Escobar
> nelson@myri.com
>
> _______________________________________________
> ia64-dist mailing list
> ia64-dist@turbolinux.com
> http://www.turbolinux.com/mailman/listinfo/ia64-dist

--
Uros Prestor
uros@turbolinux.com




