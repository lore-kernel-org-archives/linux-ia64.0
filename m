From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 06 Sep 2001 18:19:28 +0000
Subject: Re: [Linux-ia64] IA64 Linux Kernel Page Sizes
Message-Id: <marc-linux-ia64-105590698805132@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805131@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805131@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 6 Sep 2001 11:22:54 -0500, "Donny Cooper" <dcooper@atcc.necsys.com> said:

  Donny> (1) Below is a previous mail, from David M., responding to
  Donny> page size questions for IA64 kernels.

  >> As for the future: I'd like to start playing with superpage
  >> support fairly soon (once I get some spare time on my
  >> hands... ;-).  With superpages, physically contiguous regions of
  >> memory could be mapped with a single TLB entry, giving you most
  >> of the benefit of (very) large page sizes. --david

  Donny> Are there any updates on these plans?

Nope, not yet.

  Donny> (2) Below are current available kernel options (from config).

  Donny> 4KB For best IA-32 compatibility 8KB For best IA-64
  Donny> performance 16KB For best IA-64 performance 64KB Not for
  Donny> Itanium.

  Donny> What is "IA64 best performance" based on?

Don made a bunch of measurement.  I tried both local and NFS-mounted
kernel compiles.  Both benefited from 16KB page size.  I never tried
64KB page size.  I'm not sure it's worth bothering with it on Itanium
(but I'm always willing to consider evidence to the contrary... ;-).

  Donny> We have a large memory system (32GB), and are not concerned
  Donny> with wasting memory during certain benchmarks.  Are 64KB
  Donny> pages truly not functional on Itanium, or just not
  Donny> recommended because of memory waste.  To my knowledge, HP-UX
  Donny> seems to benefit from 64KB pages on ITANIUM.

  Donny> Any input or recommendation on these items is appreciated.

No, 64KB page size functions fine on Itanium, it's just that we don't
support it in Linux (due to some silly limits that you'll run into).
I think Jack Steiner from SGI posted some patches to work around those
issues.  I'd play with those first if you're interested in this.

	--david


