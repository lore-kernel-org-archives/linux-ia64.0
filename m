From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 07 Feb 2005 19:30:42 +0000
Subject: prezeroing V6 [0/3]: Changes and overview
Message-Id: <Pine.LNX.4.58.0502071127470.27951@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0501211228430.26068@schroedinger.engr.sgi.com>
 <1106828124.19262.45.camel@hades.cambridge.redhat.com> <20050202153256.GA19615@logos.cnet>
In-Reply-To: <20050202153256.GA19615@logos.cnet>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org
Cc: torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Changes from V4 to V6:
o V5 posted as independent patches
o copyright update in Altix BTE driver
o Note early work on __GFP_ZERO by Andrea Arcangeli
o Simplify Altix BTE zeroing driver and handle timeouts correctly
  (kscrubd hung once in a while).
o Support /proc/buddyinfo
o Make the higher order clear_page patch less invasive. Name it clear_pages.
o patch against 2.6.11-rc3

More information and a combined patchset is available at
http://oss.sgi.com/projects/page_fault_performance.

The most expensive operation in the page fault handler is (apart of SMP
locking overhead) the touching of all cache lines of a page by
zeroing the page. This zeroing means that all cachelines of the faulted
page (on Altix that means all 128 cachelines of 128 byte each) must be
handled and later written back. This patch allows to avoid having to
use all cachelines  if only a part of the cachelines of that page is
needed immediately after the fault. Doing so will only be effective for
sparsely accessed memory which is typical for anonymous memory and pte maps.
Prezeroed pages will only be used for those purposes. Unzeroed pages
will be used as usual for file mapping, page caching etc etc.

The patch makes prezeroing very effective by:

1. Appplying zeroing operations only to pages of higher order, which results
in many pages that will later become zero order pages to be zeroed in one
step.

2. Hardware support for offloading zeroing from the cpu. This avoids
the invalidation of the cpu caches by extensive zeroing operations.

The scrub daemon is invoked when a unzeroed page of a certain order has
been generated so that its worth running it. If no higher order pages are
present then the logic will favor hot zeroing rather than simply shifting
processing around. kscrubd typically runs only for a fraction of a second
and sleeps for long periods of time even under memory benchmarking. kscrubd
performs short bursts of zeroing when needed and tries to stay out off the
processor as much as possible.

The benefits of prezeroing are reduced to minimal quantities if all
cachelines of a page are touched. Prezeroing can only be effective
if the whole page is not immediately used after the page fault.

The patch is composed of 3 parts:

[1/3] clear_pages(page, order) to zero higher order pages
	Adds a clear_pages function with the ability to zero higher order
	pages. This allows the zeroing of large areas of memory without repeately
	invoking clear_page() from the page allocator, scrubd and the huge
	page allocator.

[2/3] Page Zeroing
	Adds management of ZEROED and NOT_ZEROED pages and a background daemon
	called scrubd.

[3/3] SGI Altix Block Transfer Engine Support
	Implements a driver to shift the zeroing off the cpu into hardware.
	This avoids the potential impact of zeroing on cpu caches.

