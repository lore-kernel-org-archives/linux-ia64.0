From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 24 May 2002 18:00:38 +0000
Subject: Re: [Linux-ia64] [PATCH] compilation fixes for i460 with 2.5.1[5-7] kernels
Message-Id: <marc-linux-ia64-105590701905596@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905594@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905594@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 24 May 2002 15:26:34 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Since 2.5.15, a few interfaces are no longer exported from
  Peter> filemap.c --- which means the code for getting and releasing
  Peter> locked pages in files .../agp/agpgart_be.c, .../drm/radeon.c,
  Peter> and .../drm/r128_cce.c has to be changed.

  Peter> Question: Is it *really* necessary to lock these pages?  As
  Peter> they're grabbed from the freepage list, they're not backed by
  Peter> a file, so noone else will ever try to get the page.  (Or
  Peter> have I misunderstood completely what's going on here?)  So
  Peter> what's it locking against?

I believe the locking is bogus.  I'm no AGP expert, but my
understanding is that what's going on there is that the agp code is
allocating an scatter/gather table which is accessed by the GART
("AGP's DMA engine").  This table can be mapped into user level.  I
suspect the intent of the original code was to prevent swap-outs
etc. on those pages.  However, that's already taken care of by the
vm-area which is used to map the memory into user level: it has the
VM_RESERVED flag set (see drm_vm.h).

BTW: I'm finally back to working on the 2.5 tree.  I hope to have a
(preliminary) 2.5.17 patch sometime today.

	--david

