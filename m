From: "Akbar A." <syedali011@earthlink.net>
Date: Wed, 19 Jul 2000 09:35:03 +0000
Subject: RE: [Linux-ia64] Re: Support for more than 2GB RAM
Message-Id: <marc-linux-ia64-105590678205209@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205208@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205208@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>and I can only use 2GB of my 4GB machine?
pardon my naivety, but wasn't the whole point of moving to the the 64 bit
architecture was to push and solve the problems of--
	o larger numbers.
	o allowing more memory.
	o larger number transactions (finance and tax applications)
	o large disk sizes, etc..
	o higher precision in scientfic simulators, and other simuation machines.
As well as to get ride of the control Microsoft has over the IBM's and
dells. Just had to add that bit in there, read the court findings you know.


take care,
akbar A.

"We want technology for the sake of the story, not for its own sake. When
you look back, say 10 years from now, current technology will seem quaint"
Pixars' Edwin Catmull.


-----Original Message-----
From: linux-ia64-admin@linuxia64.org
[mailto:linux-ia64-admin@linuxia64.org]On Behalf Of Christoph Rohland
Sent: Wednesday, July 19, 2000 4:07 AM
To: davidm@hpl.hp.com
Cc: linux-ia64@linuxia64.org
Subject: [Linux-ia64] Re: Support for more than 2GB RAM


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

Linux version 2.4.0-0.8smp (root@boris.devel.redhat.com) (gcc version
2.9-ia64-0
00216-final) #1 SMP Sun Jun 18 00:32:35 EDT 2000
EFI v0.92 by INTEL AL460GX.86B.0027.D27.021800: SALsystab=0x7ff29d60
ACPI=0x7ffd
9718 MPS=0x7ffd0000
map_pal_code: mapping PAL code [0x7ff40000-0x7ff7b000) into
[0xe00000007fc00000-
0xe000000080000000)
Warning: ignoring 0MB of memory above 1GB!
Warning: ignoring 0MB of memory above 1GB!
Warning: ignoring 2046MB of memory above 1GB!

and I can only use 2GB of my 4GB machine?

Greetings
		Christoph



_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64



