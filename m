From: Jack Steiner <steiner@sgi.com>
Date: Thu, 03 May 2001 12:30:31 +0000
Subject: Re: Re: [Linux-ia64] NMI handling
Message-Id: <marc-linux-ia64-105590693005527@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>
> I'm trying to add an NMI oopser to ia64 kdb to help debug disabled
> spinloops.  I can add the NMI handler but AFAICT I am wasting my time.
> local_irq_save and friends do rsm psr.i which will mask all interrupts,
> including NMI (arch volume 2, table 5-7).

I agree.

I cant speak to how other platforms use NMI/INIT.

As far as SNIA is concerned, we dont use what Itanium describes
as NMI,

On SNIA, the traditional NMI signal that the chipset understands
is sent to the cpu chip as an INIT.  INIT gets propagated thru
the PAL/SAL and shows up in linux at ia64_init_handler().

We have also added an "init" command to kdb (arch/ia64/kdbasupport.c) 
to send the INIT signal to other cpus that dont respond to CTL-A.
Last time I checked, it was working ok & allowed you to get into kdb on
cpus that did not respond to CTL-A. You can see the register state
on these cpus but traceback thru an MCA/INIT frame doesnt currently
work. Resuming after an INIT doest work either.



---- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


