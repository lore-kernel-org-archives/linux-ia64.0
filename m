From: William Lee Irwin III <wli@holomorphy.com>
Date: Wed, 14 Mar 2007 00:41:08 +0000
Subject: Re: [QUICKLIST 0/6] Arch independent quicklists V1
Message-Id: <20070314004108.GL2986@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com> <20070312.155157.74747634.davem@davemloft.net>
In-Reply-To: <20070312.155157.74747634.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, ak@suse.com, holt@sgi.com, linux-ia64@vger.kernel.org, mpm@selenic.com

On Mon, Mar 12, 2007 at 03:51:57PM -0700, David Miller wrote:
> Someone with some extreme patience could do the sparc 32-bit port too,
> in fact it's lacking the cached PGD update logic that x86 et al. have
> so it would even end up being a bug fix :-)  This lack is why sparc32
> pre-initializes the vmalloc/module area PGDs with static page tables
> at boot time, FWIW.

I'll spare everyone the details and let code if/when it appears stand
in for promises on the sparc32 front.


-- wli
