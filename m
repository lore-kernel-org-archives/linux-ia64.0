From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Jun 2003 20:41:01 +0000
Subject: Re: SCSI ERRORS triggered by BIO_VMERGE_BOUNDARY
Message-Id: <marc-linux-ia64-105640089624756@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105604433402604@msgid-missing>
In-Reply-To: <marc-linux-ia64-105604433402604@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 Jun 2003 13:24:03 -0700, Grant Grundler <iod00d@hp.com> said:

  Grant> On Mon, Jun 23, 2003 at 09:52:06AM -0700, David Mosberger
  Grant> wrote:
  >> No, BIO_VMERGE_BOUNDARY must be 0xffffffffffffffff if there is no
  >> hardware I/O MMU present (i.e., the I/O MMU page size is 2^64)
  >> and PAGE_SIZE if an I/O MMU is present (which can support
  >> PAGE_SIZE pages).

  Grant> yes - that's what I thought. I'm just having problems
  Grant> counting tildes.

  Grant> #define BIO_VMERGE_BOUNDARY (0UL)//(ia64_max_iommu_merge_mask
  Grant> + 1)

  Grant> Which for sba_iommu should have been:
  Grant> (ia64_max_iommu_merge_mask + 1) = (~IOVP_MASK + 1)   Grant> (~PAGE_MASK + 1) = (~(~(PAGE_SIZE-1)) + 1) = PAGE_SIZE

  Grant> (I hope I have that right now)

Yes.  You can thank Linus for the "inverted" sense of PAGE_MASK
(though it does make sense in the VM layer).

  >> the bio-level code _assumes_ that discontiguous physical pages
  >> can be remapped linearly by the I/O MMU code.  If the I/O MMU
  >> code doesn't actually do the merging, the kernel will fall flat
  >> on its face.

  Grant> uhmm...why does the bio-level code care what can/can't be
  Grant> merged if it's not going to do it?

  Grant> Seems like a waste of CPU cycles to walk the sg_list an extra
  Grant> time in the IOMMU code to figure what can (and will) be
  Grant> merged.  My gut feeling is bio-level code doesn't know enough
  Grant> to do it efficiently and the IOMMU code needs to walk the
  Grant> list at least once to program the HW (effectively twice if
  Grant> sba_iommu wants to attempt coalescing).

Well, I'm not a disk person (if it doesn't fit in memory, you don't
have enough of it! ;-), but the basic assumption is that it is
worthwhile to spend a few CPU cycles on forming fewer, but larger disk
requests whenever possible.  Intuitively, that certainly makes sense
to me, though I haven't seen any performance numbers on how much of a
difference this can make.  You'd certainly need a disk-heavy workload
to see any difference.  Perhaps Rohit could try it on TPC-C (once the
merging is working)?

The decision has to be split across BIO and I/O MMU: only the
BIO-level knows what to do if merging _cannot_ take place and only the
I/O MMU code knows how to map physically discontiguous pages linearly
into I/O MMU space.

	--david
