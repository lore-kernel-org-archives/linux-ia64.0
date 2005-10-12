From: Robin Holt <holt@sgi.com>
Date: Wed, 12 Oct 2005 02:26:27 +0000
Subject: [Patch 0/2] ia64 special memory support.
Message-Id: <20051012022627.GA32360@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-mm@kvack.org

SGI hardware supports a special type of memory called fetchop or atomic
memory. This memory does atomic operations at the memory controller
instead of using the processor.  It has, however, shown itself to be
slower than the processor since many times that a lock is grabbed,
the cacheline ownership is retained in the processor and the unlock is
nearly free.

This patch set introduces a driver so userland can map these devices
and fault pages of the appropriate type.

Since a typical uncached page does not have a page struct backing it, we
first modify do_no_page to handle a new return type of NOPAGE_FAULTED.
This indicates to the nopage handler that the desired operation is
complete and should be treated as a minor fault.

The second patch introduces the mspec driver.

Thanks, Robin Holt
