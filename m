From: Paul Mackerras <paulus@samba.org>
Date: Sat, 22 Jan 2005 02:53:27 +0000
Subject: Re: Extend clear_page by an order parameter
Message-Id: <16881.49191.918994.413281@cargo.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
	<Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
	<20050108135636.6796419a.davem@davemloft.net>
	<Pine.LNX.4.58.0501211210220.25925@schroedinger.engr.sgi.com>
	<16881.33367.660452.55933@cargo.ozlabs.ibm.com>
	<Pine.LNX.4.58.0501211545080.27045@schroedinger.engr.sgi.com>
	<16881.40893.35593.458777@cargo.ozlabs.ibm.com>
	<20050121164353.6f205fbc.akpm@osdl.org>
	<16881.43936.632734.780383@cargo.ozlabs.ibm.com>
	<Pine.LNX.4.58.0501211749300.27677@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0501211749300.27677@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, davem@davemloft.net, hugh@veritas.com, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Christoph Lameter writes:

> I had the name "zero_page" in V1 and V2 of the patch where it was
> separate. Then someone complained about code duplication.

Well, if you duplicated each arch's clear_page implementation in
zero_page, then yes, that would be unnecessary code duplication.  I
would suggest that for architectures where the clear_page
implementation can easily be extended, rename it to clear_page_order
(or something) and #define clear_page(x) to be clear_page_order(x, 0).
For architectures where it can't, leave clear_page as clear_page and
define clear_page_order as an inline function that calls clear_page in
a loop.

> clear_page is called clear_page because it clears one page of *any* order
> not just higher orders. zero-order pages are not segregated nor are they
> intrisincally better just because they contain more memory ;-).

You have missed my point, which was about address constraints, not a
distinction between zero-order pages and higher-order pages.

Anyway, I remain of the opinion that your naming is inconsistent with
the naming of other functions that deal with zero-order and
higher-order pages, such as get_free_pages, alloc_pages, free_pages,
etc., and that your patch is unnecessarily intrusive.  I guess it's up
to Andrew to decide which way we go.

Paul.
