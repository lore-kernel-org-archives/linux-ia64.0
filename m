From: "David S. Miller" <davem@redhat.com>
Date: Thu, 15 May 2003 23:46:19 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705861@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Colin Ngam <cngam@sgi.com>
   Date: Thu, 15 May 2003 18:25:54 -0500
   
   Actually, our system does not have Physical Memory Address smaller than
   48Bits - give or take couple bits ...  Hence, 32Bits Mapped DMA address
   maps to 48Bits System Physical Address.

If you support mapping 32-bit DMA bus spaces to the full 48-bit
physical memory spaces, then why do you even need >4GB addressing?

Saying that PCI-X devices can only generate DAC cycles is bogus,
I have PCI-X tg3 cards in my systems and they function just fine.
Or does this rule only apply when the device is on a PCI-X bus?

This all sounds seriously broken to me, I thought the issue was that
a) the addresses could not be translated, it was direct phys-->virt
and b) you can't guarentee that the physical address of memory
allocated on any particular node is <4GB.

