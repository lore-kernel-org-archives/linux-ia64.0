From: Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 05 Jun 2017 08:00:39 +0000
Subject: Re: [PATCH 5/5] remove non-uapi <asm/siginfo.h>
Message-Id: <alpine.DEB.2.20.1706050959000.3517@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170603190102.28866-1-hch@lst.de> <20170603190102.28866-6-hch@lst.de> <alpine.DEB.2.20.1706041510440.2813@nanos> <20170605071821.GA21343@lst.de>
In-Reply-To: <20170605071821.GA21343@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Arnd Bergmann <arnd@arndb.de>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 5 Jun 2017, Christoph Hellwig wrote:
> On Sun, Jun 04, 2017 at 03:13:11PM +0200, Thomas Gleixner wrote:
> > On Sat, 3 Jun 2017, Christoph Hellwig wrote:
> > 
> > > By moving the kernel side __SI_* defintions right next to the userspace
> > > ones we can kill the non-uapi versions of <asm/siginfo.h> include
> > > include/asm-generic/siginfo.h and untangle the unholy mess of includes.
> > 
> > That needs a couple of fixups and we can remove
> > 
> > arch/X/include/uapi/asm/siginfo.h from m32r, microblaze, mn10300 and score.
> > 
> > Delta patch below.
> 
> Thanks.  I'm going to include this if I have to resend for some reason.

No need. I already folded it in and it survived the built bot testing w/o
complaints. About to push it out into tip timers/core as I have the posix
timer stuff pending on top of it.

Thanks,

	tglx

