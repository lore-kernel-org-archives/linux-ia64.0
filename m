From: Andrew Morton <akpm@osdl.org>
Date: Wed, 05 Jan 2005 00:47:20 +0000
Subject: Re: Prezeroing V3 [1/4]: Allow request for zeroed memory
Message-Id: <20050104164720.3863d312.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com>
	<41C20E3E.3070209@yahoo.com.au>
	<Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412231132170.31791@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412231133130.31791@schroedinger.engr.sgi.com>
	<Pine.GSO.4.61.0501011123550.27452@waterleaf.sonytel.be>
	<Pine.LNX.4.58.0501041510430.1536@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0501041629490.4111@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0501041629490.4111@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: clameter@sgi.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Linus Torvalds <torvalds@osdl.org> wrote:
>
> On Tue, 4 Jan 2005, Christoph Lameter wrote:
> >
> > This patch introduces __GFP_ZERO as an additional gfp_mask element to allow
> > to request zeroed pages from the page allocator.
> 
> Ok, let's start merging this slowly

One week hence, please.  Things like the no-bitmaps-for-the-buddy-allocator
have been well tested and should go in first.
