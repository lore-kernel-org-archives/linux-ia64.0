From: Christoph Rohland <cr@sap.com>
Date: Wed, 19 Jul 2000 09:07:15 +0000
Subject: [Linux-ia64] Re: Support for more than 2GB RAM
Message-Id: <marc-linux-ia64-105590678205208@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

> >>>>> On 18 Jul 2000 14:40:42 +0200, Christoph Rohland <cr@sap.com> said:
> 
>   Christoph> Hi, Are there any plans to support more than 2GB RAM in
>   Christoph> the near future?
> 
> There never was a limit for 2GB.  4GB is no problem and more than 4GB
> works fine also except if there are 32-bit PCI devices that do DMA (or
> the machine has huge holes in the physical address space, which isn't
> true for the prototypes).  For the DMA issue, a solution is in the
> works (Goutham has been working on this).

So why do I get the following:

Linux version 2.4.0-0.8smp (root@boris.devel.redhat.com) (gcc version 2.9-ia64-0
00216-final) #1 SMP Sun Jun 18 00:32:35 EDT 2000
EFI v0.92 by INTEL AL460GX.86B.0027.D27.021800: SALsystab=0x7ff29d60 ACPI=0x7ffd
9718 MPS=0x7ffd0000
map_pal_code: mapping PAL code [0x7ff40000-0x7ff7b000) into [0xe00000007fc00000-
0xe000000080000000)
Warning: ignoring 0MB of memory above 1GB!
Warning: ignoring 0MB of memory above 1GB!
Warning: ignoring 2046MB of memory above 1GB!

and I can only use 2GB of my 4GB machine?

Greetings
		Christoph



