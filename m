From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 13 May 2002 19:03:46 +0000
Subject: Re: [Linux-ia64] more prefetch/vga issues
Message-Id: <marc-linux-ia64-105590701905577@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905576@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905576@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 13 May 2002 09:12:03 -0600, Alex Williamson <alex_williamson@hp.com> said:

  Alex>    Thanks to Asit's patch a while back, we've seen a lot less
  Alex> MCA's from accesses to the VGA range.  There still seems to be
  Alex> one lurking though.  I've traced it down to the prefetching in
  Alex> free_one_pgd().  This function prefetches farther than it
  Alex> needs to, and can easily try to prefetch from the VGA MMIO
  Alex> region at 0xa0000.  On an HP zx1 system, this causes an MCA if
  Alex> the VGA card doesn't respond.

Again, prefetching arbitrary addresses is always valid.  So, by
definition, it's not the lfetch that's broken (though it may be a bad
idea to do it anyhow, for performance reasons, but that's a different
issue).

  Alex>    There seem to be (at least) two solutions to this.  One is
  Alex> to modify mm/memory.c such that it only prefetches to the
  Alex> extent that it uses.  This might have some performance
  Alex> implications, but they're likely minimal.

We would have to show that.  At the moment, we use an "asm" to do the
lfetch, so it can't be predicated (we need to look into using
__builtin_prefetch() instead; hopefully that one can be predicated).
And on other archiectures, the performance effect of adding the check
may be more noticable.

On the other hand, the major reason for doing the prefetch is to get
good execve() performance on SMP, and for SMP, extraneous prefetching
can be quite hurtful.  So you might have a pretty good argument for
not prefetching past the end of the page on all architectures.  But I
we'd still have to back it up with numbers.

  Alex> The other
  Alex> alternative, is that efi_memmap_walk() could detect this
  Alex> situation, and ignore a page of memory.  This can be a generic
  Alex> test, just checking for usable memory directly adjacent to
  Alex> MMIO.

Yes, I think we need to put in such a test.  However, it should check
for any overlap of a UC/WC-only area with a "granule" that contains WB
areas, where a "granule" is a 16 or 64MB page.  Actually, if we put in
this test, there should be less need for the 16MB granule size
anymore.  Of course, we may end up throwing a lot of memory that way.
We should print a warning at least, so that users can see how much
memory is being ignored (and why).

I think this is a reasonable workaround until we get around to fixing
the <64MB memory attribute aliasing issues in a better way.

	--david

