From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jan 2002 19:56:06 +0000
Subject: Re: [Linux-ia64] kmalloc() and page sizes
Message-Id: <marc-linux-ia64-105590698805796@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805788@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805788@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 10 Jan 2002 11:18:49 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> Hi all!  In the current kernels the size limit for
  Christian> kmalloc() is 128KB. The ia64 architecture provides
  Christian> pagesizes ranging from 4K, ... , 64K, 256K, ... , 4G. If
  Christian> we would increase the maximum kmalloc() size limit to
  Christian> 256K (or 1M) this would match perfectly to the pagesizes.

  Christian> Since I need a large (256K) segment from kmalloc(), I
  Christian> would appreciate the increase of the size limit. Maybe
  Christian> also other 64Bit architectures could benefit from that.

  Christian> Please tell your opinion to the list.

Is there a reason you can't use alloc_pages() directly?  It can handle
allocation orders of up to 10 (not that you'll find many chunks of
that size!).  The slab allocator is limited to an allocation order of
5, as you observed.

	--david

