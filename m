From: Arjan van de Ven <arjanv@redhat.com>
Date: Mon, 03 Dec 2001 22:10:33 +0000
Subject: Re: [Linux-ia64] Re: PATCH: performance problems with swiotlb.c
Message-Id: <marc-linux-ia64-105590698805592@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805584@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805584@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 03, 2001 at 02:06:08PM -0800, David Mosberger wrote:
> >>>>> On Mon, 3 Dec 2001 15:27:47 -0500, Arjan van de Ven <arjanv@redhat.com> said:
> 
>   Arjan> Unfortionatly the idea of a software MMU is broken by
>   Arjan> design. The current DMA API does not allow for one in
>   Arjan> practice, and, thankfully, there's also no need for one. The
>   Arjan> linux kernel allows perfectly well for systems without IO MMU
>   Arjan> and will do the right thing at higher layers, where things
>   Arjan> CAN be done properly (for example, the software IOMMU cannot
>   Arjan> sleep to wait for memory and hence panic()'s the kernel in
>   Arjan> this case, while the higher layers often can either sleep (in
>   Arjan> the case of the blockdevice layer) or just drop the packet on
>   Arjan> near-OOM in the case of the network layer.
> 
> But longer term, the question is whether it is better to support
> multiple bounce buffer schemes or whether the PCI DMA interface should
> be enhanced to better handle "out of memory" situations.  In my
> opinion, it would be better to enhance the PCI DMA interface with a
> throttling/OOM-feedback mechanism.

Fully agreed and this appears to be the plan for 2.5 

> Note that even with hardware I/O TLB, you can get into such
> situations.  The only real difference is that the software I/O TLB
> consumes memory primarily as a functiion of the amount of data being
> buffered, whereas a hardware I/O TLB it's primarily limited by the
> number of *descriptors* needed.

yes; I can imagine the 2.5 scenario be "try the hw io mmu and if not, report
failure" at which point the higher layer does it's thing (either blocks for
resources to become available or to drop the network packet). The "highmem"
scenario would be a the 2.4 scenario, and the scenario where you don't have
a real io mmu.

Greetings,
   Arjan van de Ven

