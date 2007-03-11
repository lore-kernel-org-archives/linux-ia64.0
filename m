From: William Lee Irwin III <wli@holomorphy.com>
Date: Sun, 11 Mar 2007 03:22:13 +0000
Subject: Re: [QUICKLIST 2/6] i386: quicklist support
Message-Id: <20070311032213.GJ2986@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com> <20070311020934.19905.57850.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070311020934.19905.57850.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, ak@suse.com, linux-ia64@vger.kernel.org, holt@sgi.com, mpm@selenic.com

On Sat, Mar 10, 2007 at 06:09:34PM -0800, Christoph Lameter wrote:
> i386: Convert to quicklists
> Implement the i386 management of pgd and pmds using quicklists.

I approve, though it would be nice if ptes had an interface operating
on struct page * to use.


On Sat, Mar 10, 2007 at 06:09:34PM -0800, Christoph Lameter wrote:
> The i386 management of page table pages currently uses page sized slabs.
> The page state is therefore mainly determined by the slab code. However,
> i386 also uses its own fields in the page struct to mark special pages
> and to build a list of pgds using the ->private and ->index field (yuck!).
> This has been finely tuned to work right with SLAB but SLUB needs more
> control over the page struct. Currently the only way for SLUB to support
> these slabs is through special casing PAGE_SIZE slabs.
> If we use quicklists instead then we can avoid the mess, and also the
> overhead of manipulating page sized objects through slab.

Hey! I did quite well given the constraints under which I was operating.


-- wli
