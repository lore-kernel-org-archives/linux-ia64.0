From: Andrew Morton <akpm@osdl.org>
Date: Tue, 22 Feb 2005 10:03:09 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <20050222020309.4289504c.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net>
In-Reply-To: <16923.193.128608.607599@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@trained-monkey.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

jes@trained-monkey.org (Jes Sorensen) wrote:
>
> Hi,
> 
> This patch introduces ia64 specific read/write handlers for /dev/mem
> access which is needed to avoid uncached pages to be accessed through
> the cached kernel window which can lead to random corruption. It also
> introduces a new page-flag PG_uncached which will be used to mark the
> uncached pages. I assume this may be useful to other architectures as
> well where the CPU may use speculative reads which conflict with
> uncached access. In addition I moved do_write_mem to be under
> ARCH_HAS_DEV_MEM as it's only ever used if that is defined.
> 
> The patch is needed for the new ia64 special memory driver (mspec -
> former fetchop).
> 
> Patch is relative to 2.6.11-rc3-mm2 and relies on the ARCH_HAS_DEV_MEM
> flag which isn't in Linus' nor Tony's trees yet.

Is it possible to avoid consuming a page flag?

If this is an ia64-only (or 64-bit-only) thing I guess we could use bit 32.

> +		if (page->flags & PG_uncached)

dude.  That ain't gonna work ;)
