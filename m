From: "David S. Miller" <davem@davemloft.net>
Date: Thu, 24 Mar 2005 18:58:39 +0000
Subject: Re: recent fix for pgd_addr_end
Message-Id: <20050324105839.69ec0d75.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
In-Reply-To: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 24 Mar 2005 10:45:09 -0800
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> Do we really need to worry about region-crossing in the pgd_addr_end()
> macro?  No single vm_area may cros a region boundary.

clear_page_range() walks the page tables across the entire
address space and thus across VMA's.

That's why the macro overrides were necessary, to cope with that.

With Hugh Dickin's stuff, we will be doing clear_page_range() via
VMAs and thus eliminate this ugly stuff.

This has all been spelled out pretty explicitly in the various
threads.
