From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Wed, 19 Jul 2000 17:18:52 +0000
Subject: RE: [Linux-ia64] Re: Support for more than 2GB RAM
Message-Id: <marc-linux-ia64-105590678205216@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205208@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205208@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We are making good progress with the PCI DMA implementation and we should
have a patch by end of this week. This will remove the 2GB RAM check adn
will use all the memory in the system.

--Asit


> -----Original Message-----
> From: David Mosberger [mailto:davidm@hpl.hp.com]
> Sent: Wednesday, July 19, 2000 8:22 AM
> To: Christoph Rohland
> Cc: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] Re: Support for more than 2GB RAM
> 
> 
> You should be able to change that check to 4GB without ill effects.
> (The 1GB check is there for historical reasons.)  Anyhow, if this
> isn't urgent, I'd just wait until Goutham is done with the PCI DMA
> implementation and then that check will go away completely.
> 
> 	--david
> 
> >>>>> On 19 Jul 2000 11:07:15 +0200, Christoph Rohland 
> <cr@sap.com> said:
> 
>   Christoph> David Mosberger <davidm@hpl.hp.com> writes:
>   >> >>>>> On 18 Jul 2000 14:40:42 +0200, Christoph Rohland
>   >> <cr@sap.com> said:
>   >> 
>   Christoph> Hi, Are there any plans to support more than 2GB RAM in
>   Christoph> the near future?
>   >>  There never was a limit for 2GB.  4GB is no problem and more
>   >> than 4GB works fine also except if there are 32-bit PCI devices
>   >> that do DMA (or the machine has huge holes in the physical
>   >> address space, which isn't true for the prototypes).  For the DMA
>   >> issue, a solution is in the works (Goutham has been working on
>   >> this).
> 
>   Christoph> So why do I get the following:
> 
>   Christoph> Linux version 2.4.0-0.8smp (root@boris.devel.redhat.com)
>   Christoph> (gcc version 2.9-ia64-0 00216-final) #1 SMP Sun Jun 18
>   Christoph> 00:32:35 EDT 2000 EFI v0.92 by INTEL
>   Christoph> AL460GX.86B.0027.D27.021800: SALsystab=0x7ff29d60
>   Christoph> ACPI=0x7ffd 9718 MPS=0x7ffd0000 map_pal_code: mapping PAL
>   Christoph> code [0x7ff40000-0x7ff7b000) into [0xe00000007fc00000-
>   Christoph> 0xe000000080000000) Warning: ignoring 0MB of memory above
>   Christoph> 1GB!  Warning: ignoring 0MB of memory above 1GB!
>   Christoph> Warning: ignoring 2046MB of memory above 1GB!
> 
>   Christoph> and I can only use 2GB of my 4GB machine?
> 
>   Christoph> Greetings Christoph
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 



