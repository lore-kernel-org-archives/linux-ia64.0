From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 06 Jun 2017 10:57:11 +0000
Subject: Re: untangle the <asm/siginfo.h> mess
Message-Id: <CAK8P3a05TaU_x97+egQHyptPQ5x8iq3=U9PVEwaFfjohJ-pVwg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170603190102.28866-1-hch@lst.de>
In-Reply-To: <20170603190102.28866-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-arch <linux-arch@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, Jun 3, 2017 at 9:00 PM, Christoph Hellwig <hch@lst.de> wrote:
> We currently have uapi versions of <asm/siginfo.h> which at least on a few
> architectures define bits of the userspace ABI before including an uapi
> asm-generic version, and also non-uapi versions which do almost nothing
> except for making sure other headers include the right uapi one before
> including an asm-generic that defined two prototypes and a few defines
> that aren't architecture specific in any.
>
> This series completely gets rid of the non-uapi versions and cleans up
> various small bits on the way.
>
> Note that Thomas has some posix-timers work overlapping with this, so
> it might make sense to take these through the tip tree.

Yes, makes sense. For asm-generic:

Acked-by: Arnd Bergmann <arnd@arndb.de>
