From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 05 Mar 2002 20:09:31 +0000
Subject: RE: [Linux-ia64] Fix for for memory leak in IA32 mmap
Message-Id: <marc-linux-ia64-105590701905229@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905222@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905222@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 5 Mar 2002 11:44:20 -0800 , "Luck, Tony" <tony.luck@intel.com> said:

  Tony> I'm not sure that you really need a list ... in fact if you
  Tony> have a list, I think that I can still come up with
  Tony> pathalogical programs that will break: E.g. I might use
  Tony> several mmap() calls to set up some blocks of memory, but
  Tony> clear them all with one call to munmap() that spans them all,
  Tony> or I might not do any munmap() at all and just mmap(MAP_FIXED)
  Tony> things onto the same addresses (since mmap will throw away
  Tony> existing mappings before creating new ones). Just using the
  Tony> bitmap to determine whether to round up the end (and round
  Tony> down the start) address of munmap() requests based on whether
  Tony> the partial pages have been used should solve most of the
  Tony> problems.

That clearly would be wrong.  I think Don was planning to handle the
other cases you're mentioning as well.

  Tony> IA-32 programs are limited to the bottom 4G of address space,
  Tony> and they believe that it is divided into 2^20 * 4KB pages.  A
  Tony> bitmap for the whole of that would be 128KB, which might be
  Tony> somewhat high of an overhead for every IA-32 program ... but a
  Tony> two-level table would most likely be very sparsely filled,
  Tony> limiting the memory overhead to something acceptable.

Sounds like an interesting idea.

  Tony> Even with this change, there will still be programs that can
  Tony> only work correctly with a 4k kernel pagesize (e.g. a program
  Tony> that maps a 4K page from two different files, read+write into
  Tony> the same 16K page)

Certainly.  Anyone interested in exploring subpage support?  This
could also be useful for I/O devices...  I am somewhat doubtful that
the benefits would outweight the costs, but with some clever ideas,
perhaps it would be possible to make it work for the important cases
without incurring the full cost.

	--david

