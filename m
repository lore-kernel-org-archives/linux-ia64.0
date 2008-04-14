From: Brent Casavant <bcasavan@sgi.com>
Date: Mon, 14 Apr 2008 19:40:37 +0000
Subject: Re: [2.6 patch] add SGI_IOC4 hardware dependencies
Message-Id: <alpine.BSF.1.10.0804141404190.52763@pkunk.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080413181543.GF2182@cs181133002.pp.htv.fi>
In-Reply-To: <20080413181543.GF2182@cs181133002.pp.htv.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 13 Apr 2008, Adrian Bunk wrote:

> Considering that all users of this code depend on
> (IA64_SGI_SN2 || IA64_GENERIC) the SGI_IOC4 option
> should also depend on it.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Tony,

Please don't apply this yet.  I'll need some guidance from Adrian
and you on how to proceed.

The IOC4 chip _is_ available on a PCI card for x86 based systems.
And that is why I removed the dependence of the config option on
IA64_SGI_SN2 || IA64_GENERIC.

Unfortunately the only user of IOC4 on x86 is the "external interrupt"
IOC4 sub-driver which is available under the GPL, but was not accepted
into the Linux kernel.  I just realized that this driver is supplied
to SGI's customers (and they're free to modify and distribute it as
per the GPL -- there's no problems there), but I neglected to ever
make it available for download from http://oss.sgi.com.  I'll be happy
to fix that oversight.

On IA64 the IOC4 IDE and serial sub-drivers (in the mainline kernel), as
well as the external interrupt sub-driver (available seperately), are
available.

I'm not sure exactly how to approach this problem because the IOC4 is
a bit unique.  Since it is a single PCI device, I cannot register
entirely seperate device drivers for each of the three distinct
hardware functionalities it provides -- only a single driver can own the
PCI device.  At the same time, the one function for which we need the
card on x86 has its device driver maintained out-of-tree, so Adrian's
patch makes perfect sense from the purely in-kernel perspective.

History: Due to the odd nature of IOC4 hardware (and IOC3 for that matter),
I split off the low-level "here's how to drive the hardware" portion of
the external interrupt driver from the "here's the interface to user space"
portion, along with an interface between the two.  I submitted a patch for
this several years ago.  Of course, as you can probably predict, this was
panned as being far too complex for the one piece of hardware that uses it
-- which is true.

However, it does lay the groundwork for the MIPS folks to write the IOC3
sub-driver for external interrupts if they should so choose (IOC3 is used
on the Octane and certain Origin 2000 machines), and take advantage of the
user space portion of the external interrupt driver.  They've even asked
me a few questions about this at a few points in time.  Anyway, what we
end up with is a situation where the set of external interrupt drivers
isn't accepted into the mainline kernel, but SGI has in good faith made the
drivers available under the GPL.

So I'm kind of left in a difficult position with this one.  I understand
the desire to make the change Adrian offered, but it then makes it very
difficult to support the GPL'd external interrupt driver on x86.

Any guidance?

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
