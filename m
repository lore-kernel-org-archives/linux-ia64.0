From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 23 Aug 2007 07:27:15 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <1187854035.5972.4.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
	<alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, linux-ia64@vger.kernel.org, Jesse Barnes <jesse.barnes@intel.com>, linuxppc-dev@ozlabs.org


> Of course, the normal memory barrier would usually be a "spin_unlock()" or 
> something like that, not a "wmb()". In fact, I don't think the powerpc 
> implementation (as an example of this) will actually synchronize with 
> anything *but* a spin_unlock().

We are even more sneaky in the sense that we set a per-cpu flag on any
MMIO write and do the sync automatically in spin_unlock() :-)

Ben.


