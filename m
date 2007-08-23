From: Jesse Barnes <jesse.barnes@intel.com>
Date: Thu, 23 Aug 2007 16:56:16 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <200708230956.17049.jesse.barnes@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
	<alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
	<1187854035.5972.4.camel@localhost.localdomain>
In-Reply-To: <1187854035.5972.4.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nick Piggin <npiggin@suse.de>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linuxppc-dev@ozlabs.org

On Thursday, August 23, 2007 12:27 am Benjamin Herrenschmidt wrote:
> > Of course, the normal memory barrier would usually be a
> > "spin_unlock()" or something like that, not a "wmb()". In fact, I
> > don't think the powerpc implementation (as an example of this) will
> > actually synchronize with anything *but* a spin_unlock().
>
> We are even more sneaky in the sense that we set a per-cpu flag on
> any MMIO write and do the sync automatically in spin_unlock() :-)

Yeah, that's a reasonable thing to do, and in fact I think there's code 
to do something similar when a task is switched out (this keeps user 
level drivers from having do mmiowb() type things).

FWIW, I think I had an earlier version of the patch that used the name 
pioflush() or something similar, the only confusing thing about that 
name is that the primitive doesn't actually force I/Os down to the 
device level, just to the closest bridge.

It'll be interesting to see if upcoming x86 designs share this problem 
(e.g. large HT or CSI topologies).

Jesse
