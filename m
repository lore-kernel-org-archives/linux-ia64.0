From: Russ Anderson <rja@sgi.com>
Date: Fri, 02 May 2008 00:41:00 +0000
Subject: [PATCH 0/3] ia64: Migrate data off physical pages with correctable errors v2
Message-Id: <20080502004100.GA12006@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>, Russ Anderson <rja@sgi.com>

	Migrate data off physical pages with corrected memory errors

Version 2 changes:

	Broke the page.discard patch into two patches, per request by 
	Christoph Lameter.  

	page.cleanup.v2: 
		- minor clean-up of page flags in page_alloc.c.  

	page.discard.v2:
		- Updated for recent page flag clean-up.
		- Removed the change to the sysinfo struct.

	cpe.migrate.v2
		- Added /proc/badram interface to print page discard
		  information and to free bad pages.

Purpose:

	Physical memory with corrected errors may decay over time into
	uncorrectable errors.  The purpose of this patch is to move the
	data off pages with correctable memory errors before the memory
	goes bad.

The patches:

  [1/3] page.cleanup.v2: Minor clean-up of page flags in mm/page_alloc.c

	Minor source code clean-up of page flags in mm/page_alloc.c.
	No functional change.

  [2/3] page.discard.v2: Avoid putting a bad page back on the LRU.

	page.discard are the arch independent changes.  It adds a new
	page flag (PG_memerror) to mark the page as bad and prevent it
	from being put back on the LRU.  PG_memerror is only defined
	on 64 bit architectures. 

  [3/3] cpe.migrate.v2: Call migration code on correctable errors

	cpe.migrate are the IA64 specific changes.  It connects the CPE
	handler to the page migration code.  It is implemented as a kernel
	loadable module, similar to the mca recovery code (mca_recovery.ko),
	so that it can be removed to turn off the feature.  Add /proc/badram
	to print page discard and to free bad pages.

Comments:

	There is always an issue of how agressive the code should be on
	migrating pages.  Should it migrate on the first correctable error,
	or wait for some threshold?  Reasonable people may disagree on the
	threshold and the "right" answer may be hardware specific.  The 
	decision making is confined to the cpe_migrate.c code.  It is
	currently set to migrate on the first correctable error.

	Only pages that can be isolated on the LRU are migrated.  Other
	pages, such as compound pages, are not migrated.  That functionality
	could be a future enhancement.

	/proc/badram is a way of displaying information about the bad
	memory and freeing the bad pages.  A userspace program (or sysadmin)
	could determine if a discarded page needs to be freed.

Sample output:

	linux> insmod cpe_migrate.ko
	linux> cat /proc/badram			// This shows no discarded memory
	Bad RAM: 0 kB, 0 pages marked bad
	List of bad physical pages

	linux> ./errsingle -c 6 -s 1		// Inject correctable errors on
						// six pages.
	linux> cat /proc/badram
	Bad RAM: 384 kB, 6 pages marked bad
	List of bad physical pages
	  0x06048e10000  0x06870c40000  0x06870c20000  0x06870c10000  0x06007f00000
	  0x06042070000

	linux> echo 0x06870c20000 > /proc/badram	// Free one of the pages

	linux> cat /proc/badram			// Five pages remain on the list
	Bad RAM: 320 kB, 5 pages marked bad
	List of bad physical pages
	  0x06048e10000  0x06870c40000  0x06870c10000  0x06007f00000  0x06042070000

	linux> echo 0 > /proc/badram		// Free all the bad pages
	linux> cat /proc/badram			// All the pages are freed
	Bad RAM: 0 kB, 0 pages marked bad
	List of bad physical pages



Flow of the code description (while testing on IA64):

	1) A user level application test program allocates memory and
	   passes the virtual address of the memory to the error injection
	   driver.

	2) The error injection driver converts the virtual address to
	   physical, functions the Altix hardware to modify the ECC for the
	   physical page, creating a correctable error, and returns to the
	   user application.

	3) The user application reads the memory.

	4) The Altix hardware detects the correctable error and interrupts
	   prom.  SAL builds a CPU error record, then sends a CPE 
	   interrupt to linux.

	5) The linux CPE handler calls the cpe_migrate module (if installed).

	6) cpe_migrate parses the physical address from the CPE record and
	   adds the address to the migrate list (if not already on the list)
	   and schedules the worker thread (cpe_enable_work).

	7) cpe_enable_work calls ia64_mca_cpe_move_page.

	8) ia64_mca_cpe_move_page validates the physical address, converts
	   to page, sets PG_memerror flag and calls the migration code
	   (migrate_prep(), isolate_lru_page(), and migrate_pages().  If the
	   page migrates successfully, the bad page is added to badpagelist.

	9) Because PG_memerror is set, the bad page is not added back on the LRU
	   due to checks in lru_cache_add() and lru_cache_add_active().

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
