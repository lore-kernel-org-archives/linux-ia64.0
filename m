From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 30 May 2002 05:49:57 +0000
Subject: Re: [Linux-ia64] Missing files in to-linus-2.5 BK tree; build problems
Message-Id: <marc-linux-ia64-105590701905619@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905608@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905608@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

David> Note that the to-linus-2.5 tree is intended for Linus only.
David> It's not complete in any fashion (well, some day it will
David> be...).  I am working on the latest 2.5 patch, but keep getting
David> delayed (and of course Linus keeps cranking out new
David> versions...).

Doesn't he just!

It seems to me that there are several categories of things in the
patches you've been cranking out.

1. Support for devices not in the main tree (e.g., the i460GX, the
  qlogic 2200, etc)

2. Extra features (like the early printk support) that in their 
  current form are too ugly to go into the mainline, but are really
  useful for IA64.

3. Changes in architecture specific code for
  -- matching changes in mainline code (e.g., the scatterlist change,
  the TLB shootdown change, etc)
  -- enhancements to IA64-specific code (like the new perfmon support)
  -- New subarchitectures (e.g., SN1, ZX1)


4. Changes in mainline to fix things that break on IA64.
   (e.g., ACPI)

It seems to me that it *should* be possible to get all except category
2 synced into the mainline code.  One of the things I've been trying
to do occasionally is to compile a ia64-patched kernel on different
architectures to see what breaks.  Surprisingly little does.

BTW, I upgraded the BIOS on lemon.gelato.unsw.edu.au, the machine that
had the time haring off into the future.  It seems OK now.

One of the BIOS notes said that the AGP aperture for the I460GX was
fixed not to overlap the PCI space.  Does this mean that some of the
hacks in the DRM are no longer necessary?

--
Peter C					    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.



