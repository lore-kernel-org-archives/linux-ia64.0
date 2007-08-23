From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 23 Aug 2007 07:25:51 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <1187853952.5972.2.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
In-Reply-To: <20070822045714.GD26374@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-ia64@vger.kernel.org, Jesse Barnes <jesse.barnes@intel.com>, linuxppc-dev@ozlabs.org

On Wed, 2007-08-22 at 06:57 +0200, Nick Piggin wrote:

> It doesn't seem like this primary function of mmiowb has anything to do
> with a write barrier that we are used to (it may have a seconary semantic
> of a wmb as well, but let's ignore that for now). A write barrier will
> never provide you with those semantics (writes from 2 CPUs seen in the
> same order by a 3rd party). If anything, I think it is closer to being
> a read barrier issued on behalf of the target device.  But even that I
> think is not much better, because the target is not participating in the
> synchronisation that the CPUs are, so the "read barrier request" could
> still arrive at the device out of order WRT the other CPU's writes.
> 
> It really seems like it is some completely different concept from a
> barrier. And it shows, on the platform where it really matters (sn2), where
> the thing actually spins.

The way mmiowb was actually defined to me by the ia64 folks who came up
with it is essentially to order an MMIO write with a spin_unlock.

Ben.


