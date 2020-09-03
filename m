From: Nicolin Chen <nicoleotsuka@gmail.com>
Date: Thu, 03 Sep 2020 03:26:00 +0000
Subject: Re: [PATCH 0/2] dma-mapping: update default segment_boundary_mask
Message-Id: <20200903032559.GA4517@Asurada-Nvidia>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200901221646.26491-1-nicoleotsuka@gmail.com>
 <2c8db0aa-e8b5-e577-b971-1de10ecc6747@linux.ibm.com>
In-Reply-To: <2c8db0aa-e8b5-e577-b971-1de10ecc6747@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Niklas Schnelle <schnelle@linux.ibm.com>
Cc: hch@lst.de, sfr@canb.auug.org.au, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, gerald.schaefer@linux.ibm.com, hca@linux.ibm.com, gor@linux.ibm.com, borntraeger@de.ibm.com, linux-s390@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, x86@kernel.org, hpa@zytor.com, James.Bottomley@HansenPartnership.com, deller@gmx.de, linux-parisc@vger.kernel.org

On Wed, Sep 02, 2020 at 10:13:12AM +0200, Niklas Schnelle wrote:
> On 9/2/20 12:16 AM, Nicolin Chen wrote:
> > These two patches are to update default segment_boundary_mask.
> > 
> > PATCH-1 fixes overflow issues in callers of dma_get_seg_boundary.
> > Previous version was a series: https://lkml.org/lkml/2020/8/31/1026
> > 
> > Then PATCH-2 sets default segment_boundary_mask to ULONG_MAX.
> > 
> > Nicolin Chen (2):
> >   dma-mapping: introduce dma_get_seg_boundary_nr_pages()
> >   dma-mapping: set default segment_boundary_mask to ULONG_MAX
> 
> I gave both of your patches a quick test ride on a couple of dev mainframes,
> both NVMe, ConnectX and virtio-pci devices all seems to work fine.
> I already commented on Christoph's mail that I like the helper approach,
> so as for s390 you can add my
> 
> Acked-by: Niklas Schnelle <schnelle@linux.ibm.com>
 
Thanks for testing and the ack! 
