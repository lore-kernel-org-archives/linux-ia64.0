From: Grant Grundler <iod00d@hp.com>
Date: Mon, 23 Jun 2003 07:11:19 +0000
Subject: Re: SCSI ERRORS triggered by BIO_VMERGE_BOUNDARY
Message-Id: <marc-linux-ia64-105635245808996@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105604433402604@msgid-missing>
In-Reply-To: <marc-linux-ia64-105604433402604@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 19, 2003 at 10:36:34AM -0700, David Mosberger wrote:
> If I set BIO_VMERGE_BOUNDARY to 0, the errors disappear.

Hmm...convoluted code.
./arch/ia64/kernel/setup.c:unsigned long ia64_max_iommu_merge_mask = ~0UL;

arch/ia64/hp/common/sba_iommu.c:
	#define IOVP_MASK	PAGE_MASK
...
        if ((long) ~IOVP_MASK > (long) ia64_max_iommu_merge_mask)
			ia64_max_iommu_merge_mask = ~IOVP_MASK;


AFAICT, that's the equivalent to (PAGE_SIZE-1) > (-1) on the first round.
Or did I missed a tilde?

I'd think that ia64 wants:

	#define BIO_VMERGE_BOUNDARY (~ia64_max_iommu_merge_mask + 1)
or
	#define BIO_VMERGE_BOUNDARY PAGE_SIZE

(If I've accounted for tildes properly.)

It looks like a few other arches do something like that:
./include/asm-ppc64/io.h:#define BIO_VMERGE_BOUNDARY    4096
./include/asm-sparc64/io.h:#define BIO_VMERGE_BOUNDARY  8192

(BTW, PARISC probably wants to use 4K pages as well).


> My suspicion is that something is wrong in the sba_iommu.c code
> with respect to block merging.

There might well be. It's easy to get the block merging code
wrong when merging random chunks which can be bigger or smaller
than PAGE_SIZE. My gut feeling this can all get ripped out of
2.5 sba_iommu.c if the bio code is going to merge for us. That
means pci_map_sg() support only needs to map each address/len
pair and forget trying to merge them.

hth,
grant
