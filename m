From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 12 May 2003 18:40:18 +0000
Subject: Re: [Linux-ia64] new ia64 kernel patch (relative to 2.5.69)
Message-Id: <marc-linux-ia64-105590723705733@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705721@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705721@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Forgot to mention that I switched the ia64 tree from the PCI-DMA API
to the generic DMA API.  Doesn't affect device drivers, but all I/O
MMU support needs to be updated accordingly.  I already did swiotlb
and the HP SBA I/O MMU support.  I updated that machvec definitions
for all platforms, but didn't try to update the SN-specific
implementation (since I can't test it anyhow).  Updating the SN-files
should be straight-forward: you can look at swiotlb.c and
hp/common/sba_iommu.c for what needs to be done.

The one caveat is that sba_iommu.c for the moment continues to support
only PCI-devices.  This shouldn't be a problem for now, but it would
be nice if someone could fix it so it can work with any device.

While working on this, I started to wonder whether or not a DMA "sync"
operation should imply a memory barrier.  The API documentation is
definitely ambiguous on this point and I didn't go out to look whether
current practice is consistent (I suspect it isn't).  Anyone want to
argue for or against making "sync" a memory barrier?

	--david

