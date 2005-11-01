From: Bob Picco <bob.picco@hp.com>
Date: Tue, 01 Nov 2005 00:25:28 +0000
Subject: Re: Recent SPARSEMEM and DISCONTIG changes break some builds
Message-Id: <20051101002528.GJ6019@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <17253.37207.664571.236714@wombat.chubb.wattle.id.au>
In-Reply-To: <17253.37207.664571.236714@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

luck wrote:	[Mon Oct 31 2005, 02:00:46PM EST]
> >Your build must be against -mm because pfn_to_kaddr shouldn't be required
> >in 2.6.14.  The patch below will fix this.
> 
> I was building 2.6.14+(all the bits in Linus' git tree that I pulled
> at about 8:30 PST today).  Presumably this bit has already been moved
> from -mm to -linus?
Actually you are correct. I just updated my local Linus' git tree and 
pfn_to_kaddr is now required for ia64 because of changes in mm/sparse.c.
> 
> Thanks for the patch, I'll give it a spin.
your welcome.
> 
> -Tony
> -
bob
