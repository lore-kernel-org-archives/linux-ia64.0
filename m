From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 22 Sep 2003 19:39:40 +0000
Subject: Re: [HELP] latest discontig
Message-Id: <marc-linux-ia64-106425978523413@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106305453930076@msgid-missing>
In-Reply-To: <marc-linux-ia64-106305453930076@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


  Jesse> Here's the latest discontig patch.  It seems to be working
  Jesse> for everybody, but could always use more testing.

  Jesse> Unfortunately, I haven't been able to come up with a good way
  Jesse> to make the functions reentrant wrt the new cdata structure.
  Jesse> Everything I come up with is much uglier than what's there,
  Jesse> and even more obtuse, so I'd really appreciate suggestions.
  Jesse> Personally, I'd like to see David merge this patch to make an
  Jesse> intrusive cleanup of the memory initialization code easier
  Jesse> :).

You know, you'd greatly increase the chance of my applying the patch
if the patch:

 - were broken up into reasonably small, self-contained pieces
 - doesn't actually BREAK the existing ia64 platforms
 - looks like the author(s) actually cared about they were doing

I'm sorry, but until some of these criteria are met, there is no way
I'm going to apply this patch.  As for the breakage: as far as I can
see, the patch moves the bootmem initialization back to the old place,
which means that drivers/acpi/tables.c will fail to allocate memory
for the SDT again.

Some other comments:

 - in acpi.c, it looks like there is no reason for min_hole_size anymore,
   yet the patch doesn't clean up this variable

 - MAX_RSVD_REGIONS et al got moved to pgtable.h; why in the world would
   that be the right place?  Just because "it compiled"??

 - why is there both vmem_map and mem_map in the NUMA case?

	--david
