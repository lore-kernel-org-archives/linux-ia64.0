From: Linus Torvalds <torvalds@osdl.org>
Date: Thu, 02 Dec 2004 00:10:18 +0000
Subject: Re: page fault scalability patch V12 [0/7]: Overview and performance
Message-Id: <Pine.LNX.4.58.0412011608500.22796@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
 <Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org>
 <Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org>
 <Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org



On Wed, 1 Dec 2004, Christoph Lameter wrote:
>
> Changes from V11->V12 of this patch:
> - dump sloppy_rss in favor of list_rss (Linus' proposal)
> - keep up against current Linus tree (patch is based on 2.6.10-rc2-bk14)
> 
> This is a series of patches that increases the scalability of
> the page fault handler for SMP. Here are some performance results
> on a machine with 512 processors allocating 32 GB with an increasing
> number of threads (that are assigned a processor each).

Ok, consider me convinced. I don't want to apply this before I get 2.6.10 
out the door, but I'm happy with it. I assume Andrew has already picked up 
the previous version.

		Linus
