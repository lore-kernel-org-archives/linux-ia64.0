From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Jun 2003 16:52:06 +0000
Subject: Re: SCSI ERRORS triggered by BIO_VMERGE_BOUNDARY
Message-Id: <marc-linux-ia64-105638713909251@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105604433402604@msgid-missing>
In-Reply-To: <marc-linux-ia64-105604433402604@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 Jun 2003 00:11:19 -0700, Grant Grundler <iod00d@hp.com> said:

  Grant> Hmm...convoluted code.  ./arch/ia64/kernel/setup.c:unsigned
  Grant> long ia64_max_iommu_merge_mask = ~0UL;

  Grant> arch/ia64/hp/common/sba_iommu.c: #define IOVP_MASK PAGE_MASK
  Grant> ...  if ((long) ~IOVP_MASK > (long)
  Grant> ia64_max_iommu_merge_mask) ia64_max_iommu_merge_mask   Grant> ~IOVP_MASK;

  Grant> AFAICT, that's the equivalent to (PAGE_SIZE-1) > (-1) on the
  Grant> first round.  Or did I missed a tilde?

No, that's what it is.

  Grant> I'd think that ia64 wants:

  Grant> 	#define BIO_VMERGE_BOUNDARY (~ia64_max_iommu_merge_mask + 1)
  Grant>     or #define BIO_VMERGE_BOUNDARY PAGE_SIZE

No, BIO_VMERGE_BOUNDARY must be 0xffffffffffffffff if there is no
hardware I/O MMU present (i.e., the I/O MMU page size is 2^64) and
PAGE_SIZE if an I/O MMU is present (which can support PAGE_SIZE
pages).

  Grant> It's easy to get the block merging code wrong when merging
  Grant> random chunks which can be bigger or smaller than
  Grant> PAGE_SIZE. My gut feeling this can all get ripped out of 2.5
  Grant> sba_iommu.c if the bio code is going to merge for us. That
  Grant> means pci_map_sg() support only needs to map each address/len
  Grant> pair and forget trying to merge them.

No, you got this backwards: the bio-level code _assumes_ that
discontiguous physical pages can be remapped linearly by the I/O MMU
code.  If the I/O MMU code doesn't actually do the merging, the kernel
will fall flat on its face.

	--david
