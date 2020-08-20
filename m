From: Nicolin Chen <nicoleotsuka@gmail.com>
Date: Thu, 20 Aug 2020 23:19:23 +0000
Subject: [RFT][PATCH 0/7] Avoid overflow at boundary_size
Message-Id: <20200820231923.23678-1-nicoleotsuka@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, tony.luck@intel.com, fenghua.yu@intel.com, schnelle@linux.ibm.com, gerald.schaefer@linux.ibm.com, hca@linux.ibm.com, gor@linux.ibm.com, borntraeger@de.ibm.com, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, x86@kernel.org, hpa@zytor.com, James.Bottomley@HansenPartnership.com, deller@gmx.de
Cc: sfr@canb.auug.org.au, hch@lst.de, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-parisc@vger.kernel.org

We are expending the default DMA segmentation boundary to its
possible maximum value (ULONG_MAX) to indicate that a device
doesn't specify a boundary limit. So all dma_get_seg_boundary
callers should take a precaution with the return values since
it would easily get overflowed.

I scanned the entire kernel tree for all the existing callers
and found that most of callers may get overflowed in two ways:
either "+ 1" or passing it to ALIGN() that does "+ mask".

According to kernel defines:
    #define ALIGN_MASK(x, mask) (((x) + (mask)) & ~(mask))
    #define ALIGN(x, a)	ALIGN_MASK(x, (typeof(x))(a) - 1)

We can simplify the logic here:
  ALIGN(boundary + 1, 1 << shift) >> shift
= ALIGN_MASK(b + 1, (1 << s) - 1) >> s
= {[b + 1 + (1 << s) - 1] & ~[(1 << s) - 1]} >> s
= [b + 1 + (1 << s) - 1] >> s
= [b + (1 << s)] >> s
= (b >> s) + 1

So this series of patches fix the potential overflow with this
overflow-free shortcut.

As I don't think that I have these platforms, marking RFT.

Thanks
Nic

Nicolin Chen (7):
  powerpc/iommu: Avoid overflow at boundary_size
  alpha: Avoid overflow at boundary_size
  ia64/sba_iommu: Avoid overflow at boundary_size
  s390/pci_dma: Avoid overflow at boundary_size
  sparc: Avoid overflow at boundary_size
  x86/amd_gart: Avoid overflow at boundary_size
  parisc: Avoid overflow at boundary_size

 arch/alpha/kernel/pci_iommu.c    | 10 ++++------
 arch/ia64/hp/common/sba_iommu.c  |  4 ++--
 arch/powerpc/kernel/iommu.c      | 11 +++++------
 arch/s390/pci/pci_dma.c          |  4 ++--
 arch/sparc/kernel/iommu-common.c |  9 +++------
 arch/sparc/kernel/iommu.c        |  4 ++--
 arch/sparc/kernel/pci_sun4v.c    |  4 ++--
 arch/x86/kernel/amd_gart_64.c    |  4 ++--
 drivers/parisc/ccio-dma.c        |  4 ++--
 drivers/parisc/sba_iommu.c       |  4 ++--
 10 files changed, 26 insertions(+), 32 deletions(-)

-- 
2.17.1
