From: Grant Grundler <iod00d@hp.com>
Date: Mon, 23 Jun 2003 20:24:03 +0000
Subject: Re: SCSI ERRORS triggered by BIO_VMERGE_BOUNDARY
Message-Id: <marc-linux-ia64-105640005723820@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105604433402604@msgid-missing>
In-Reply-To: <marc-linux-ia64-105604433402604@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jun 23, 2003 at 09:52:06AM -0700, David Mosberger wrote:
> No, BIO_VMERGE_BOUNDARY must be 0xffffffffffffffff if there is no
> hardware I/O MMU present (i.e., the I/O MMU page size is 2^64) and
> PAGE_SIZE if an I/O MMU is present (which can support PAGE_SIZE
> pages).

yes - that's what I thought. I'm just having problems counting tildes.

#define BIO_VMERGE_BOUNDARY   (0UL)//(ia64_max_iommu_merge_mask + 1)

Which for sba_iommu should have been:
   (ia64_max_iommu_merge_mask + 1)
		= (~IOVP_MASK + 1)
		= (~PAGE_MASK + 1)
		= (~(~(PAGE_SIZE-1)) + 1)
		= PAGE_SIZE

(I hope I have that right now)

> No, you got this backwards:

:^(

> the bio-level code _assumes_ that
> discontiguous physical pages can be remapped linearly by the I/O MMU
> code.  If the I/O MMU code doesn't actually do the merging, the kernel
> will fall flat on its face.

uhmm...why does the bio-level code care what can/can't be merged if
it's not going to do it?

Seems like a waste of CPU cycles to walk the sg_list an extra time
in the IOMMU code to figure what can (and will) be merged.  My gut
feeling is bio-level code doesn't know enough to do it efficiently
and the IOMMU code needs to walk the list at least once to program
the HW (effectively twice if sba_iommu wants to attempt coalescing).

thanks,
grant
