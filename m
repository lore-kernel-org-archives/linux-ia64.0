From: Roman Zippel <zippel@linux-m68k.org>
Date: Sat, 22 Jan 2005 01:20:49 +0000
Subject: Re: Extend clear_page by an order parameter
Message-Id: <Pine.LNX.4.61.0501220219390.6118@scrub.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
 <Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
 <20050108135636.6796419a.davem@davemloft.net>
 <Pine.LNX.4.58.0501211210220.25925@schroedinger.engr.sgi.com>
 <16881.33367.660452.55933@cargo.ozlabs.ibm.com>
 <Pine.LNX.4.58.0501211545080.27045@schroedinger.engr.sgi.com>
 <16881.40893.35593.458777@cargo.ozlabs.ibm.com> <20050121164353.6f205fbc.akpm@osdl.org>
In-Reply-To: <20050121164353.6f205fbc.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Paul Mackerras <paulus@samba.org>, clameter@sgi.com, davem@davemloft.net, hugh@veritas.com, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On Fri, 21 Jan 2005, Andrew Morton wrote:

> Paul Mackerras <paulus@samba.org> wrote:
> >
> > A cluster of 2^n contiguous pages
> >  isn't one page by any normal definition.
> 
> It is, actually, from the POV of the page allocator.  It's a "higher order
> page" and is controlled by a struct page*, just like a zero-order page...

OTOH we also have alloc_page/alloc_pages.

bye, Roman
