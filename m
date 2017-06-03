From: Christoph Hellwig <hch@lst.de>
Date: Sat, 03 Jun 2017 19:00:57 +0000
Subject: untangle the <asm/siginfo.h> mess
Message-Id: <20170603190102.28866-1-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

We currently have uapi versions of <asm/siginfo.h> which at least on a few
architectures define bits of the userspace ABI before including an uapi
asm-generic version, and also non-uapi versions which do almost nothing
except for making sure other headers include the right uapi one before
including an asm-generic that defined two prototypes and a few defines
that aren't architecture specific in any.

This series completely gets rid of the non-uapi versions and cleans up
various small bits on the way.

Note that Thomas has some posix-timers work overlapping with this, so
it might make sense to take these through the tip tree.
