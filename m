From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Tue, 12 Jun 2001 19:39:03 +0000
Subject: [Linux-ia64] IO-TLB buffers & aic7xxx - new results
Message-Id: <marc-linux-ia64-105590693005721@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I have made a small kernel patch that allows me to follow
the allocation and deallocation of IO-TLB buffers in the kernel.

First of all, by using a kernel command line parameter "swiotlb24",
I have not been able to crash my machine anymore (however, this is for
1 controller and using only 1 disk).

On average, the amount of used IO-TLB buffers on my system is between
60 and 70, each only 1 slot wide (i.e. #buffers = #occupied slots).

If I do my usual "make install" test for parted, I see the a few allocations,
but not many. Then after a few seconds when the dirty buffers are flashed
(I can make this happen immediately by doing "make install; sync"),
the IO-TLB usage peaks at 450 buffers occupying 1470 slots, i.e.
the driver allocates ~400 buffers without intermediate deallocation,
and most of them are 4 slots wide. It is interesting that more than
253 buffers seem to be requested at the same time.

What I'll do next is to try a heavier load on more than a single disk,
and perhaps several controllers at once.

At least this way I can at least give recommendations for how large to set the
swiotlb parameter with a given number of controllers.

If there's interest, I'll happily send my patch tomorrow.

I cannot see how the heuristic for allocating IO-TLB space could be
improved, given that at the moment when the memory is allocated the kernel
has no way to know how many 32-bit controllers populate its PCI slots.

Cheers,
Martin

-- Martin Wilck <Martin.Wilck@fujitsu-siemens.com> FSC EP PS DS1,
Paderborn Tel. +49 5251 8 15113





