From: "Sluder, Charles" <Charles.Sluder@UNISYS.com>
Date: Thu, 07 Nov 2002 02:52:40 +0000
Subject: RE: [Linux-ia64] [PATCH]ACPI fACS global lock & virtual memmap
Message-Id: <marc-linux-ia64-105590709805345@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805326@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805326@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I tried the patch and it gets rid of the panic.  Before and after dumps of
the memory map are below. The SAL and ACPI tables are being trimmed from the
memory map. That is why the FACS global lock is mapped uncached. Debug from
acpi_map_os_memory is also include below.

Shouldn't the trim code ignore runtime memory?=20

-chuck



EFI v1.10 by INTEL: SALsystab=3D0x7facf760 ACPI=3D0x7faeb048 ACPI 2.0=3D0xf=
7300
MPS=3D0x7fadc3b0 SMBIOS=3D0xf72b0
mem00: type=3D4, attr=3D0x9, range=3D[0x0000000000000000-0x0000000000001000=
) (0MB)
mem01: type=3D7, attr=3D0x9, range=3D[0x0000000000001000-0x000000000008a000=
) (0MB)
mem02: type=3D4, attr=3D0x9, range=3D[0x000000000008a000-0x00000000000a0000=
) (0MB)
mem03: type=3D5, attr=3D0x8000000000000009,
range=3D[0x00000000000c0000-0x0000000000100000) (0MB)
mem04: type=3D7, attr=3D0x9, range=3D[0x0000000000100000-0x0000000004400000)
(67MB)
mem05: type=3D2, attr=3D0x9, range=3D[0x0000000004400000-0x0000000004bc7000=
) (7MB)
mem06: type=3D7, attr=3D0x9, range=3D[0x0000000004bc7000-0x000000007f77e000)
(1963MB)
mem07: type=3D6, attr=3D0x8000000000000009,
range=3D[0x000000007f77e000-0x000000007fb94000) (4MB)
mem08: type=3D6, attr=3D0x8000000000000009,
range=3D[0x000000007fb94000-0x000000007fb95000) (0MB)
mem09: type=3D6, attr=3D0x8000000000000009,
range=3D[0x000000007fb95000-0x000000007fc00000) (0MB)
mem10: type=13, attr=3D0x8000000000000009,
range=3D[0x000000007fc00000-0x000000007fc3a000) (0MB)
mem11: type=3D7, attr=3D0x9, range=3D[0x000000007fc3a000-0x000000007fea0000=
) (2MB)
mem12: type=3D5, attr=3D0x8000000000000009,
range=3D[0x000000007fea0000-0x000000007fea8000) (0MB)
mem13: type=3D7, attr=3D0x9, range=3D[0x000000007fea8000-0x000000007feab000=
) (0MB)
mem14: type=3D5, attr=3D0x8000000000000009,
range=3D[0x000000007feab000-0x000000007ffff000) (1MB)
mem15: type=3D6, attr=3D0x8000000000000001,
range=3D[0x00000000ff400000-0x0000000100000000) (12MB)
mem16: type=3D7, attr=3D0x9, range=3D[0x0000000100000000-0x00000003fffff000)
(12287MB)
mem17: type=3D6, attr=3D0x8000000000000009,
range=3D[0x00000003fffff000-0x0000000400000000) (0MB)
mem18: type=3D7, attr=3D0x9, range=3D[0x0000000480000000-0x00000004fef4c000)
(2031MB)
mem19: type=3D2, attr=3D0x9, range=3D[0x00000004fef4c000-0x00000004fef4d000=
) (0MB)
mem20: type=3D7, attr=3D0x9, range=3D[0x00000004fef4d000-0x00000004fef62000=
) (0MB)
mem21: type=3D2, attr=3D0x9, range=3D[0x00000004fef62000-0x00000004fef68000=
) (0MB)
mem22: type=3D7, attr=3D0x9, range=3D[0x00000004fef68000-0x00000004fef69000=
) (0MB)
mem23: type=3D2, attr=3D0x9, range=3D[0x00000004fef69000-0x00000004fef6b000=
) (0MB)
mem24: type=3D7, attr=3D0x9, range=3D[0x00000004fef6b000-0x00000004fef70000=
) (0MB)
mem25: type=3D2, attr=3D0x9, range=3D[0x00000004fef70000-0x00000004fef72000=
) (0MB)
mem26: type=3D7, attr=3D0x9, range=3D[0x00000004fef72000-0x00000004fef77000=
) (0MB)
mem27: type=3D2, attr=3D0x9, range=3D[0x00000004fef77000-0x00000004fef79000=
) (0MB)
mem28: type=3D7, attr=3D0x9, range=3D[0x00000004fef79000-0x00000004fef7e000=
) (0MB)
mem29: type=3D2, attr=3D0x9, range=3D[0x00000004fef7e000-0x00000004fef80000=
) (0MB)
mem30: type=3D7, attr=3D0x9, range=3D[0x00000004fef80000-0x00000004fef85000=
) (0MB)
mem31: type=3D2, attr=3D0x9, range=3D[0x00000004fef85000-0x00000004fef87000=
) (0MB)
mem32: type=3D7, attr=3D0x9, range=3D[0x00000004fef87000-0x00000004fef8c000=
) (0MB)
mem33: type=3D2, attr=3D0x9, range=3D[0x00000004fef8c000-0x00000004fef8e000=
) (0MB)
mem34: type=3D7, attr=3D0x9, range=3D[0x00000004fef8e000-0x00000004fef93000=
) (0MB)
mem35: type=3D2, attr=3D0x9, range=3D[0x00000004fef93000-0x00000004fef95000=
) (0MB)
mem36: type=3D7, attr=3D0x9, range=3D[0x00000004fef95000-0x00000004fef98000=
) (0MB)
mem37: type=3D2, attr=3D0x9, range=3D[0x00000004fef98000-0x00000004fefa2000=
) (0MB)
mem38: type=3D1, attr=3D0x9, range=3D[0x00000004fefa2000-0x00000004ff000000=
) (0MB)
mem39: type=3D7, attr=3D0x9, range=3D[0x00000004ff000000-0x00000004ff456000=
) (4MB)
mem40: type=3D4, attr=3D0x9, range=3D[0x00000004ff456000-0x00000004ff801000=
) (3MB)
mem41: type=3D7, attr=3D0x9, range=3D[0x00000004ff801000-0x00000004ff91b000=
) (1MB)
mem42: type=3D4, attr=3D0x9, range=3D[0x00000004ff91b000-0x00000004ffa00000=
) (0MB)
mem43: type=3D7, attr=3D0x9, range=3D[0x00000004ffa00000-0x00000004ffe12000=
) (4MB)
mem44: type=3D5, attr=3D0x8000000000000009,
range=3D[0x00000004ffe12000-0x00000004ffe80000) (0MB)
mem45: type=3D7, attr=3D0x9, range=3D[0x00000004ffe80000-0x00000004fffc1000=
) (1MB)
mem46: type=3D6, attr=3D0x8000000000000009,
range=3D[0x00000004fffc1000-0x0000000500000000) (0MB)
mem47: type=12, attr=3D0x8000000000000001,
range=3D[0x00000ffffc000000-0x0000100000000000) (64MB)



mem00: type=3D4, attr=3D0x9, range=3D[0x0000000000000000-0x0000000000001000=
) (0MB)
mem01: type=3D7, attr=3D0x9, range=3D[0x000000000008a000-0x000000000008a000=
) (0MB)
mem02: type=3D4, attr=3D0x9, range=3D[0x000000000008a000-0x00000000000a0000=
) (0MB)
mem03: type=3D5, attr=3D0x8000000000000009,
range=3D[0x00000000000c0000-0x0000000000100000) (0MB)
mem04: type=3D7, attr=3D0x9, range=3D[0x0000000001000000-0x0000000004400000)
(52MB)
mem05: type=3D2, attr=3D0x9, range=3D[0x0000000004400000-0x0000000004bc7000=
) (7MB)
mem06: type=3D7, attr=3D0x9, range=3D[0x0000000004bc7000-0x000000007f000000)
(1956MB)
mem07: type=3D6, attr=3D0x8000000000000009,
range=3D[0x000000007f77e000-0x000000007f77e000) (0MB)
mem08: type=3D6, attr=3D0x8000000000000009,
range=3D[0x000000007fb94000-0x000000007fb94000) (0MB)
mem09: type=3D6, attr=3D0x8000000000000009,
range=3D[0x000000007fb95000-0x000000007fb95000) (0MB)
mem10: type=13, attr=3D0x8000000000000009,
range=3D[0x000000007fc00000-0x000000007fc00000) (0MB)
mem11: type=3D7, attr=3D0x9, range=3D[0x000000007fc3a000-0x000000007fc3a000=
) (0MB)
mem12: type=3D5, attr=3D0x8000000000000009,
range=3D[0x000000007fea0000-0x000000007fea0000) (0MB)
mem13: type=3D7, attr=3D0x9, range=3D[0x000000007fea8000-0x000000007fea8000=
) (0MB)
mem14: type=3D5, attr=3D0x8000000000000009,
range=3D[0x000000007feab000-0x000000007feab000) (0MB)
mem15: type=3D6, attr=3D0x8000000000000001,
range=3D[0x00000000ff400000-0x0000000100000000) (12MB)
mem16: type=3D7, attr=3D0x9, range=3D[0x0000000100000000-0x00000003fffff000)
(12287MB)
mem17: type=3D6, attr=3D0x8000000000000009,
range=3D[0x00000003fffff000-0x0000000400000000) (0MB)
mem18: type=3D7, attr=3D0x9, range=3D[0x0000000480000000-0x00000004fef4c000)
(2031MB)
mem19: type=3D2, attr=3D0x9, range=3D[0x00000004fef4c000-0x00000004fef4d000=
) (0MB)
mem20: type=3D7, attr=3D0x9, range=3D[0x00000004fef4d000-0x00000004fef62000=
) (0MB)
mem21: type=3D2, attr=3D0x9, range=3D[0x00000004fef62000-0x00000004fef68000=
) (0MB)
mem22: type=3D7, attr=3D0x9, range=3D[0x00000004fef68000-0x00000004fef69000=
) (0MB)
mem23: type=3D2, attr=3D0x9, range=3D[0x00000004fef69000-0x00000004fef6b000=
) (0MB)
mem24: type=3D7, attr=3D0x9, range=3D[0x00000004fef6b000-0x00000004fef70000=
) (0MB)
mem25: type=3D2, attr=3D0x9, range=3D[0x00000004fef70000-0x00000004fef72000=
) (0MB)
mem26: type=3D7, attr=3D0x9, range=3D[0x00000004fef72000-0x00000004fef77000=
) (0MB)
mem27: type=3D2, attr=3D0x9, range=3D[0x00000004fef77000-0x00000004fef79000=
) (0MB)
mem28: type=3D7, attr=3D0x9, range=3D[0x00000004fef79000-0x00000004fef7e000=
) (0MB)
mem29: type=3D2, attr=3D0x9, range=3D[0x00000004fef7e000-0x00000004fef80000=
) (0MB)
mem30: type=3D7, attr=3D0x9, range=3D[0x00000004fef80000-0x00000004fef85000=
) (0MB)
mem31: type=3D2, attr=3D0x9, range=3D[0x00000004fef85000-0x00000004fef87000=
) (0MB)
mem32: type=3D7, attr=3D0x9, range=3D[0x00000004fef87000-0x00000004fef8c000=
) (0MB)
mem33: type=3D2, attr=3D0x9, range=3D[0x00000004fef8c000-0x00000004fef8e000=
) (0MB)
mem34: type=3D7, attr=3D0x9, range=3D[0x00000004fef8e000-0x00000004fef93000=
) (0MB)
mem35: type=3D2, attr=3D0x9, range=3D[0x00000004fef93000-0x00000004fef95000=
) (0MB)
mem36: type=3D7, attr=3D0x9, range=3D[0x00000004fef95000-0x00000004fef98000=
) (0MB)
mem37: type=3D2, attr=3D0x9, range=3D[0x00000004fef98000-0x00000004fefa2000=
) (0MB)
mem38: type=3D1, attr=3D0x9, range=3D[0x00000004fefa2000-0x00000004ff000000=
) (0MB)
mem39: type=3D7, attr=3D0x9, range=3D[0x00000004ff000000-0x00000004ff456000=
) (4MB)
mem40: type=3D4, attr=3D0x9, range=3D[0x00000004ff456000-0x00000004ff801000=
) (3MB)
mem41: type=3D7, attr=3D0x9, range=3D[0x00000004ff801000-0x00000004ff91b000=
) (1MB)
mem42: type=3D4, attr=3D0x9, range=3D[0x00000004ff91b000-0x00000004ffa00000=
) (0MB)
mem43: type=3D7, attr=3D0x9, range=3D[0x00000004ffa00000-0x00000004ffe12000=
) (4MB)
mem44: type=3D5, attr=3D0x8000000000000009,
range=3D[0x00000004ffe12000-0x00000004ffe80000) (0MB)
mem45: type=3D7, attr=3D0x9, range=3D[0x00000004ffe80000-0x00000004fffc1000=
) (1MB)
mem46: type=3D6, attr=3D0x8000000000000009,
range=3D[0x00000004fffc1000-0x0000000500000000) (0MB)
mem47: type=12, attr=3D0x8000000000000001,
range=3D[0x00000ffffc000000-0x0000100000000000) (64MB)


ACPI: RSDP (v000 PTLTD                      ) @ 0x00000000000f7300
ACPI: RSDT (v001 PTLTD    RSDT   01540.00000) @ 0x000000007fad0e60
ACPI: FADT (v003 PTEC   Tiger4   01540.00000) @ 0x000000007fad9ba4
ACPI: SRAT (v001 UNISYS   SRAT   01540.00000) @ 0x000000007fad9c98
ACPI: IPPT (v001 UNISYS   IPPT   01540.00000) @ 0x000000007fad9df8
ACPI: MADT (v001 PTLTD    APIC   01540.00000) @ 0x000000007fad9e32
ACPI: BOOT (v001 PTLTD  $SBFTBL$ 01540.00000) @ 0x000000007fad9f88
ACPI: SPCR (v001 PTLTD  $UCRTBL$ 01540.00000) @ 0x000000007fad9fb0


acpi_os_map_memory:phys_to_virt: phys=00000000000f7300 virt=E0000000000f7300
attribute=8000000000000009
acpi_os_map_memory:ioremap: phys=000000007fad0e60 virt=C00000007fad0e60
attribute=3D 0000000000000000
acpi_os_map_memory:ioremap: phys=000000007fad0e60 virt=C00000007fad0e60
attribute=3D 0000000000000000
acpi_os_map_memory:ioremap: phys=000000007fad9ba4 virt=C00000007fad9ba4
attribute=3D 0000000000000000
acpi_os_map_memory:ioremap: phys=000000007fad9ba4 virt=C00000007fad9ba4
attribute=3D 0000000000000000
acpi_os_map_memory:ioremap: phys=000000007fad9c98 virt=C00000007fad9c98
attribute=3D 0000000000000000
acpi_os_map_memory:ioremap: phys=000000007fad9df8 virt=C00000007fad9df8
attribute=3D 0000000000000000
acpi_os_map_memory:ioremap: phys=000000007fada830 virt=C00000007fada830
attribute=3D 0000000000000000
acpi_os_map_memory:ioremap: phys=000000007fada830 virt=C00000007fada830
attribute=3D 0000000000000000
acpi_os_map_memory:ioremap: phys=000000007fad0ef0 virt=C00000007fad0ef0
attribute=3D 0000000000000000
acpi_os_map_memory:ioremap: phys=000000007fad0ef0 virt=C00000007fad0ef0
attribute=3D 0000000000000000

-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
Sent: Wednesday, November 06, 2002 4:31 PM
To: Sluder, Charles
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] [PATCH]ACPI fACS global lock & virtual memmap


>>>>> On Fri, 1 Nov 2002 16:14:43 -0600, "Sluder, Charles"
<Charles.Sluder@UNISYS.com> said:

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
		*virt =3D phys_to_virt(phys);
	} else {
		*virt =3D ioremap(phys, size);
	}

so, if FACS resides in a memory area marked WB, it *should* get mapped
into cachable space.  Can you tell us what the physical address of the
table is?  Let's hope it's not inside a granule with a hole.
Otherwise, you'll have a real problem with that machine (it wouldn't
be safe to access the table through cacheble space).

	--david

=3D=3D=3D arch/ia64/kernel/efi.c 1.16 vs edited =3D=3D--- 1.16/arch/ia64/ke=
rnel/efi.c	Wed Sep 25 19:04:16 2002
+++ edited/arch/ia64/kernel/efi.c	Wed Nov  6 15:27:03 2002
@@ -306,7 +306,7 @@
 		u64 start;
 		u64 end;
 	} prev, curr;
-	void *efi_map_start, *efi_map_end, *p, *q;
+	void *efi_map_start, *efi_map_end, *p, *q, *r;
 	efi_memory_desc_t *md, *check_md;
 	u64 efi_desc_size, start, end, granule_addr, first_non_wb_addr =3D 0;
=20
@@ -351,11 +351,10 @@
=20
 			if (!(first_non_wb_addr > granule_addr))
 				continue;	/* couldn't find enough
contiguous memory */
-		}
-
-		/* BUG_ON((md->phys_addr >> IA64_GRANULE_SHIFT) <
first_non_wb_addr); */
=20
-		trim_top(md, first_non_wb_addr);
+			for (r =3D p; r < q; r +=3D efi_desc_size)
+				trim_top(r, first_non_wb_addr);
+		}
=20
 		if (is_available_memory(md)) {
 			if (md->phys_addr + (md->num_pages <<
EFI_PAGE_SHIFT) > mem_limit) {

