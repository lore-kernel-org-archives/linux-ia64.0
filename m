From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 29 Jul 2003 22:30:45 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105951806219206@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 29 Jul 2003 15:07:01 -0700, Christopher Wedgwood <cw@sgi.com> said:

  Christopher> How about something like:

  Christopher> void* ia64_alloc_uc_page(int nodeid);
  Christopher> void ia64_free_us_page(void*);

  Christopher> as a starting point (for non-NUMA the nodeid won't be
  Christopher> interesting of course).

So the fetchop driver needs regular memory mapped as UC, just like the
MCA MINSTATE area?  If so, a UC memory allocator is certainly the way
to go.

	--david
