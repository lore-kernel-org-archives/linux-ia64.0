From: Jes Sorensen <jes@wildopensource.com>
Date: Sat, 17 May 2003 16:44:52 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705922@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David S Miller <davem@redhat.com> writes:

David>    From: Jes Sorensen <jes@wildopensource.com> Date: 16 May
David> 2003 17:02:36 -0400

>    How does this patch look to you? It adds the generic code
> for setting the mask, it will then be up to Colin to fix the
> SGI SN2 specific code to honor it.
   
>    I also added a patch to the tg3 driver to set the mask as it
> seems to work just dandy with 64 bit consistent addresses.
   
David> I'd hate to say this but we probably need a
David> pci_consistent_dma_supported().

Hi Dave,

I thought about this one, but from the system's point of view, I don't
see a difference between being able to do 64 bit DMA to consistent
allocations and 64 bit DMA to dynamic allocations. I'd say this is a
host adapter/driver problem for descriptor limitations as you pointed
out.

I am not strongly biased on this one, it just seems redundant to me.
I'll be happy to add it to the patch if you prefer that.

David> But this can wait and your patch is fine, EXCEPT the missing
David> documentation update :-)

I have an updated patch nearly ready, including fancy documentation
updates and Jeremy's fix to tg3.c. I will post this to linux-kernel
shortly.

Cheers,
Jes

