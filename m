From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Wed, 26 Mar 2008 00:34:13 +0000
Subject: Re: larger default page sizes...
Message-Id: <ed5aea430803251734u70f199w10951bc4f0db6262@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0803241402060.7762@schroedinger.engr.sgi.com>
	 <20080324.144356.104645106.davem@davemloft.net>
	 <Pine.LNX.4.64.0803251045510.16206@schroedinger.engr.sgi.com>
	 <20080325.162244.61337214.davem@davemloft.net>
	 <87tziu5q37.wl%peter@chubb.wattle.id.au>
In-Reply-To: <87tziu5q37.wl%peter@chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: David Miller <davem@davemloft.net>, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, ianw@gelato.unsw.edu.au

On Tue, Mar 25, 2008 at 5:41 PM, Peter Chubb <peterc@gelato.unsw.edu.au> wrote:
>  The main issue is that, at least on Itanium, you have to turn off the hardware
>  page table walker for hugepages if you want to mix superpages and
>  standard pages in the same region. (The long format VHPT isn't the
>  panacea we'd like it to be because the hash function it uses depends
>  on the page size).

Why not just repeat the PTEs for super-pages?  That won't work for
huge pages, but for superpages that are a reasonable multiple (e.g.,
16-times) the base-page size, it should work nicely.

  --david
-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
