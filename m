From: Christoph Hellwig <hch@lst.de>
Date: Tue, 25 Jun 2019 12:00:24 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <20190625120024.GA3979@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 25, 2019 at 01:21:38PM +0200, John Paul Adrian Glaubitz wrote:
> > Ok, that looks much better now with the second patch:
> > ...even after a second reboot for verification. Great!(
> > (...)
> > I assume this won't affect UMA Itaniums or should I check on one of my
> > other Integrities if this change breaks the kernel on them?
> 
> Nice! I just assume we won't be able to use the patch "as is" as it would
> potentially break other architectures if I'm not mistaken.

It doesn't actually _break_ anything, but it regresses in not doing
node local allocations.  Give me some time to dig through the ia64
code to figure out if I can make sense of this.
