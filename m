From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 06 Nov 2002 23:31:21 +0000
Subject: Re: [Linux-ia64] [PATCH]ACPI fACS global lock & virtual memmap
Message-Id: <marc-linux-ia64-105590709805343@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805326@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805326@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 1 Nov 2002 16:14:43 -0600, "Sluder, Charles" <Charles.Sluder@UNISYS.com> said:

  Sluder> The first problem was a panic in put_gate_page(). The panic
  Sluder> only occurs with CONFIG_VIRTUAL_MEMMAP enabled. The panic
  Sluder> results because there is not a pte for the kernel data
  Sluder> section.  We traced this back and found that
  Sluder> efi_memmap_walk() was indiscriminately "trimming" chunks out
  Sluder> of the first 96MB of memory in the efi memory map.

Yes, indeed, there was a bug there: the problem was that after
rounding down first_non_wb_addr to a granule-boundary, the code failed
to trim the top of all the descriptors that were part of the current
contiguous run of wb-memory.  This was part of an optimization, but
the optimization doesn't work in more complicated cases... ;-(

The patch below should fix the problem.  Can you try it and let me
know how it works?

  Sluder> The second problem encountered is a hang trying to acquire
  Sluder> the FACS global lock. The arguments passed to the acquire
  Sluder> and release macros, for the global lock, changed slightly
  Sluder> between 2.4.9 and 2.4.18. The result appears to be that the
  Sluder> address to the pointer to the global lock is being passed to
  Sluder> the macros as the lock address instead of the global lock
  Sluder> address. We tried several things to force the correct values
  Sluder> to be passed to the macro, but the only thing that has
  Sluder> worked is to change the memory constraint on the GLptr to a
  Sluder> register constraint and modify the macro appropriately.
  Sluder> This problem only occurs if the firmware supports the FACS
  Sluder> global lock. The problem will not occur on a tiger.

Yes, this clearly seems to be a bug in the ACPI code.  It's wrong to
use the "m" constraint there.  Can you send to is patch to Andy Grover
as well so it gets into ACPI mainline?

  Sluder> The third problem was an unsupported data reference fault
  Sluder> when executing the cmpxchg instruction, in the macros to
  Sluder> acquire and release the above lock.  The global lock address
  Sluder> passed to the macros was uncached. We have moved the lock
  Sluder> address into the cached memory region.  The lock is only
  Sluder> used by these macros so we don't belive this causes a
  Sluder> problem unless there is something lurking in the SAL that we
  Sluder> are unaware of.

This one is interesting.  I'm no ACPI expert but my understanding is
that the FACS table gets loaded in
tables/tbget.c:acpi_tb_get_this_table() where it gets mapped via a
call to acpi_os_map_memory().  The latter does:

	if (EFI_MEMORY_WB & efi_mem_attributes(phys)) {
		*virt = phys_to_virt(phys);
	} else {
		*virt = ioremap(phys, size);
	}

so, if FACS resides in a memory area marked WB, it *should* get mapped
into cachable space.  Can you tell us what the physical address of the
table is?  Let's hope it's not inside a granule with a hole.
Otherwise, you'll have a real problem with that machine (it wouldn't
be safe to access the table through cacheble space).

	--david

=== arch/ia64/kernel/efi.c 1.16 vs edited ==--- 1.16/arch/ia64/kernel/efi.c	Wed Sep 25 19:04:16 2002
+++ edited/arch/ia64/kernel/efi.c	Wed Nov  6 15:27:03 2002
@@ -306,7 +306,7 @@
 		u64 start;
 		u64 end;
 	} prev, curr;
-	void *efi_map_start, *efi_map_end, *p, *q;
+	void *efi_map_start, *efi_map_end, *p, *q, *r;
 	efi_memory_desc_t *md, *check_md;
 	u64 efi_desc_size, start, end, granule_addr, first_non_wb_addr = 0;
 
@@ -351,11 +351,10 @@
 
 			if (!(first_non_wb_addr > granule_addr))
 				continue;	/* couldn't find enough contiguous memory */
-		}
-
-		/* BUG_ON((md->phys_addr >> IA64_GRANULE_SHIFT) < first_non_wb_addr); */
 
-		trim_top(md, first_non_wb_addr);
+			for (r = p; r < q; r += efi_desc_size)
+				trim_top(r, first_non_wb_addr);
+		}
 
 		if (is_available_memory(md)) {
 			if (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) > mem_limit) {

