From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 03 Dec 2001 22:06:08 +0000
Subject: Re: [Linux-ia64] Re: PATCH: performance problems with swiotlb.c
Message-Id: <marc-linux-ia64-105590698805591@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805584@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805584@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 3 Dec 2001 15:27:47 -0500, Arjan van de Ven <arjanv@redhat.com> said:

  Arjan> Unfortionatly the idea of a software MMU is broken by
  Arjan> design. The current DMA API does not allow for one in
  Arjan> practice, and, thankfully, there's also no need for one. The
  Arjan> linux kernel allows perfectly well for systems without IO MMU
  Arjan> and will do the right thing at higher layers, where things
  Arjan> CAN be done properly (for example, the software IOMMU cannot
  Arjan> sleep to wait for memory and hence panic()'s the kernel in
  Arjan> this case, while the higher layers often can either sleep (in
  Arjan> the case of the blockdevice layer) or just drop the packet on
  Arjan> near-OOM in the case of the network layer.

But longer term, the question is whether it is better to support
multiple bounce buffer schemes or whether the PCI DMA interface should
be enhanced to better handle "out of memory" situations.  In my
opinion, it would be better to enhance the PCI DMA interface with a
throttling/OOM-feedback mechanism.

Note that even with hardware I/O TLB, you can get into such
situations.  The only real difference is that the software I/O TLB
consumes memory primarily as a functiion of the amount of data being
buffered, whereas a hardware I/O TLB it's primarily limited by the
number of *descriptors* needed.

	--david

