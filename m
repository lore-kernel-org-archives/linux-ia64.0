From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 30 Jul 2003 00:12:39 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105952397524058@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 29 Jul 2003 17:00:26 -0700, Christopher Wedgwood <cw@sgi.com> said:

  Christopher> On Tue, Jul 29, 2003 at 03:54:27PM -0700, David Mosberger wrote:

  >> Let's stick with a tried-and-true malloc/free-like interface (nobody
  >> every gets size arguments to free() right, do they?).

  Christopher> I'd like to claim this is too complex

I don't buy this.  Just store a header along with the actual data
(yes, accesses to the header will be slow, but nobody cares).

  Christopher> Jack also pointed out for MINSTATE handling on SN2 we
  Christopher> would want local-node pages so perhaps something like:

  Christopher> u64 ia64_uc_alloc(u64 nbytes, int nodeid, int flags);
  Christopher> void ia64_uc_free(u64 paddr);

  Christopher> Simply claim '0' is not a useful physical address in
  Christopher> this sense and thus signifies and error?

  Christopher> The 'flags' seems overly complex but would be a
  Christopher> mechanism to insist that memory is allocated from the
  Christopher> given node (as opposed to just a hint for locality).

  Christopher> Comments?

The "uc" should be changed to "ucmem" or something like that, to avoid
confusion with allocating uncached address space (what we're
allocating here is normal memory which is mapped uncached).

	--david
