From: Arjan van de Ven <arjanv@redhat.com>
Date: Mon, 03 Dec 2001 20:27:47 +0000
Subject: [Linux-ia64] Re: PATCH: performance problems with swiotlb.c
Message-Id: <marc-linux-ia64-105590698805584@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 03, 2001 at 12:12:07PM -0800, Luck, Tony wrote:
> This problem was found and this fix suggested by Dori Eldar here
> at Intel (I just critiqued it for a while and pointed out some
> corner cases that needed to be addressed).

Unfortionatly the idea of a software MMU is broken by design. The current
DMA API does not allow for one in practice, and, thankfully, there's also no
need for one. The linux kernel allows perfectly well for systems without
IO MMU and will do the right thing at higher layers, where things CAN be
done properly (for example, the software IOMMU cannot sleep to wait for
memory and hence panic()'s the kernel in this case, while the higher layers
often can either sleep (in the case of the blockdevice layer) or just drop
the packet on near-OOM in the case of the network layer. 

I'll mail a patch to implement this for ia64 to this list shortly; my
current patch is against 2.4.9 and needs forward porting to 2.4.16....

Greetings,
   Arjan van de Ven

