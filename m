From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 11 Jan 2002 16:38:52 +0000
Subject: Re: [Linux-ia64] kmalloc() and page sizes
Message-Id: <marc-linux-ia64-105590698805810@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805788@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805788@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 11 Jan 2002 13:09:11 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> David, the storage I need for my driver has to be mapped
  Christian> by the 64MB kernel page. The alloc_pages() gives me pages
  Christian> with virtual addresses outside the kernel mapped
  Christian> page. Since kmalloc() gives storage at natural alignment
  Christian> this call is perfect to overlay the storage with an
  Christian> additional mapping with 256KB page size.

The page allocator returns memory in the identity mapped kernel
segment, just like kmalloc().  In fact, kmalloc() is implemented on
top of the page allocator.  Also, the page allocator uses the buddy
system, so the memory is aligned according to the allocation order.

	--david

