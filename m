From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 11 Jan 2005 00:46:09 +0000
Subject: Re: Prezeroing V4 [1/4]: Arch specific page zeroing during page
Message-Id: <Pine.LNX.4.58.0501101645250.25962@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
 <Pine.LNX.4.58.0501100915200.19135@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0501101004230.2373@ppc970.osdl.org>
 <Pine.LNX.4.58.0501101552100.25654@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0501101553140.25654@schroedinger.engr.sgi.com>
 <20050110164157.R469@build.pdx.osdl.net>
In-Reply-To: <20050110164157.R469@build.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chris Wright <chrisw@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Linux Kernel Development <linux-kernel@vger.kernel.org>

On Mon, 10 Jan 2005, Chris Wright wrote:

> * Christoph Lameter (clameter@sgi.com) wrote:
> > @@ -1795,7 +1786,7 @@
> >
> >  		if (unlikely(anon_vma_prepare(vma)))
> >  			goto no_mem;
> > -		page = alloc_page_vma(GFP_HIGHZERO, vma, addr);
> > +		page = alloc_zeroed_user_highpage(vma, addr);
>
> Oops, HIGHZERO is gone already in Linus' tree.

Use bk13 as I indicated.
