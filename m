From: Russ Anderson <rja@sgi.com>
Date: Mon, 28 Apr 2008 19:22:52 +0000
Subject: [PATCH 0/2] ia64: Migrate data off physical pages with correctable errors
Message-Id: <20080428192252.GA14629@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>, Russ Anderson <rja@sgi.com>

	Migrate data off physical pages with corrected memory errors

Purpose:

	Physical memory with corrected errors may decay over time into
	uncorrectable errors.  The purpose of this patch is to move the
	data off pages with correctable memory errors before the memory
	goes bad.

The patches:

  [1/2] page.discard: Avoid putting a bad page back on the LRU.

	page.discard are the arch independent changes.  It adds a new
	page flag (PG_memerror) to mark the page as bad and prevent it
	from being put back on the LRU.  PG_memerror is bit 32 and only
	defined on 64 bit architectures.  It adds "BadPages:" output to
	/proc/meminfo on 64 bit architectures.  

  [2/2] cpe.migrate: Call migration code on correctable errors

	cpe.migrate are the IA64 specific changes.  It connects the CPE
	handler to the page migration code.  It is implemented as a kernel
	loadable module, similar to the mca recovery code (mca_recovery.ko),
	so that it can be removed to turn off the feature.  It exports
	three symbols (migrate_prep, isolate_lru_page, and migrate_pages).

Comments:

	Since page flags are a precious commodity on 32 bit architectures,
	the choice was made to implement PG_memerror only on 64 bit 
	architectures, in the upper 32 bits.  If there is interest in
	this feature on 32 bit, it only requires defining PG_memerror
	in one of the lower 32 page flage bits and removing the BITS_PER_LONG
	checks.

	There is always an issue of how agressive the code should be on
	migrating pages.  Should it migrate on the first correctable error,
	or wait for some threshold?  Reasonable people may disagree on the
	threshold and the "right" answer may be hardware specific.  The 
	decision making is confined to the cpe_migrate.c code.  It is
	currently set to migrate on the first correctable error.

	Only pages that can be isolated on the LRU are migrated.  Other
	pages, such as compound pages, are not migrated.  That functionality
	could be a future enhancement.

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
