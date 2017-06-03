From: David Miller <davem@davemloft.net>
Date: Sat, 03 Jun 2017 21:10:43 +0000
Subject: Re: [PATCH 1/5] sparc: simplify <asm/siginfo.h>
Message-Id: <20170603.171043.791231559479346761.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170603190102.28866-1-hch@lst.de>
        <20170603190102.28866-2-hch@lst.de>
In-Reply-To: <20170603190102.28866-2-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hch@lst.de
Cc: arnd@arndb.de, tglx@linutronix.de, tony.luck@intel.com, fenghua.yu@intel.com, linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Sat,  3 Jun 2017 21:00:58 +0200

> There is no need for the forward declaration of compat_siginfo provided
> here.  We can't yet use the generic header as we need to pull in the
> sparc-specific version of the uapi <asm/siginfo.h>, but this prepares
> for removing the non-uapi <asm/siginfo.h> entirely.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: David S. Miller <davem@davemloft.net>
