From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 21 Jan 2005 23:48:17 +0000
Subject: Re: Extend clear_page by an order parameter
Message-Id: <Pine.LNX.4.58.0501211545080.27045@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
 <Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
 <20050108135636.6796419a.davem@davemloft.net>
 <Pine.LNX.4.58.0501211210220.25925@schroedinger.engr.sgi.com>
 <16881.33367.660452.55933@cargo.ozlabs.ibm.com>
In-Reply-To: <16881.33367.660452.55933@cargo.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Mackerras <paulus@samba.org>
Cc: "David S. Miller" <davem@davemloft.net>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 22 Jan 2005, Paul Mackerras wrote:

> Christoph Lameter writes:
>
> > The zeroing of a page of a arbitrary order in page_alloc.c and in hugetlb.c may benefit from a
> > clear_page that is capable of zeroing multiple pages at once (and scrubd
> > too but that is now an independent patch). The following patch extends
> > clear_page with a second parameter specifying the order of the page to be zeroed to allow an
> > efficient zeroing of pages. Hope I caught everything....
>
> Wouldn't it be nicer to call the version that takes the order
> parameter "clear_pages" and then define clear_page(p) as
> clear_pages(p, 0) ?

clear_page clears one page of the specified order. clear_page cannot clear
multiple pages. Calling the function clear_pages would give a wrong
impression on what the function does and may lead to attempts to specify
the number of zero order pages as a parameter instead of the order.
