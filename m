From: "Wichmann, Mats D" <mats.d.wichmann@intel.com>
Date: Wed, 05 May 2004 15:15:55 +0000
Subject: mmap/munmap LSB testing help ???
Message-Id: <A06801158AE07847B27A52C1A074BC1D04C90F54@fmsmsx404.fm.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Three of the LSB tests in the mmap/munmap area have
consistently caused trouble on architectures other
than ia32 (and we think even those will cause trouble
once someone starts testing with a 4/4 split, which
at the least would need a different constant).

This has been an ongoing problem, we're just about to
give up and just stop running the tests but before
doing so I wanted to ask for help, or at least opinions.
Should this be possible?  Are the test strategies bogus
(thinking of the ia64 perspective here), and if so
would there be better ones?  Is this kind of thing even
worth testing for a large-address-space architecture?
Feel free to flame the test strategies, I didn't write them :-)


Thanks for any pointers,

Mats

=============================

Some architecture-specific constant PG is selected
such that:

mmap test assertion:
      A call to mmap() when MAP_FIXED is not specified and
      there is insufficient room in the address space to
      effect the mapping shall return MAP_FAILED and set errno 
      to ENOMEM.

test strategy:
	mmap(0, PG/2 pages, PROT_WRITE, MAP_SHARED, ...)
	mmap(0, PG-1 pages, PROT_WRITE, MAP_SHARED, ...)
      ... should fail as in assertion


mmap test assertion:
      A call to mmap() when MAP_FIXED is specified and the
      range [addr,addr+len] exceeds that allowed for the
      address space of a process shall return MAP_FAILED
      and set errno to ENOMEM.

test strategy:
      mmap(0, PG/2 pages, PROT_WRITE, MAP_SHARED, ...)
      x = mmap(0, 3 pages, PROT_NONE, MAP_SHARED, ...)
      munmap(x, 3 pages)
      mmap(x, PG-1 pages, PROT_WRITE, MAP_FIXED|MAP_SHARED, ...)
      ... should fail as in assertion


munmap test assertion:
      A call to munmap() when addresses in the range
      [addr,addr+len] are outside the valid range for the
      address space of the calling process shall return -1
      and set errno to EINVAL.

test strategy:
      mmap(0, PG/2 pages, PROT_READ, MAP_SHARED, ...)
      x = mmap(0, 2 pages, PROT_READ, MAP_SHARED, ...)
      munmap(x, PG-1 pages)
      ... should fail as in assertion
     

