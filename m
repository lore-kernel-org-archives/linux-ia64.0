From: Chris Wright <chrisw@osdl.org>
Date: Tue, 11 Jan 2005 00:41:58 +0000
Subject: Re: Prezeroing V4 [1/4]: Arch specific page zeroing during page fault
Message-Id: <20050110164157.R469@build.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain> <Pine.LNX.4.58.0501100915200.19135@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0501101004230.2373@ppc970.osdl.org> <Pine.LNX.4.58.0501101552100.25654@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0501101553140.25654@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0501101553140.25654@schroedinger.engr.sgi.com>; from clameter@sgi.com on Mon, Jan 10, 2005 at 03:54:08PM -0800
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Linux Kernel Development <linux-kernel@vger.kernel.org>

* Christoph Lameter (clameter@sgi.com) wrote:
> @@ -1795,7 +1786,7 @@
> 
>  		if (unlikely(anon_vma_prepare(vma)))
>  			goto no_mem;
> -		page = alloc_page_vma(GFP_HIGHZERO, vma, addr);
> +		page = alloc_zeroed_user_highpage(vma, addr);

Oops, HIGHZERO is gone already in Linus' tree.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
