From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 06 Nov 2002 17:32:43 +0000
Subject: Re: [Linux-ia64] [PATCH]ACPI fACS global lock & virtual memmap
Message-Id: <marc-linux-ia64-105590709805340@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805326@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805326@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 1 Nov 2002 16:14:43 -0600, "Sluder, Charles" <Charles.Sluder@UNISYS.com> said:

  Charles> The first problem was a panic in put_gate_page(). The panic
  Charles> only occurs with CONFIG_VIRTUAL_MEMMAP enabled. The panic
  Charles> results because there is not a pte for the kernel data
  Charles> section.  We traced this back and found that
  Charles> efi_memmap_walk() was indiscriminately "trimming" chunks
  Charles> out of the first 96MB of memory in the efi memory map. The
  Charles> problem appears to be that the first_non_wb_addr variable
  Charles> is not being advanced properly as the code walks through
  Charles> the efi memory descriptors. On the next pass through the
  Charles> outer loop after a hole is encountered in the memmap,
  Charles> first_non_wb_addr is usually pointing at one of the memory
  Charles> descriptors in the previous contiguous segment. It calls
  Charles> the functions to trim the memory descriptor without taking
  Charles> the memory descriptor previous to that into
  Charles> account. Basically the code goes through a contiguous
  Charles> segment, finds a hole, and then, on the next pass, trims a
  Charles> bunch of memory out of the contiguous segment. The problem
  Charles> only occurs if there are numerous holes in the efi memory
  Charles> map. The panic will not occur on a tiger.  The patch sets
  Charles> first_non_wb_addr to either the first non write back
  Charles> address it finds or to the start address in the first
  Charles> memory descriptor after a hole. We do not fully understand
  Charles> all the uses for this routine and are therefore not certain
  Charles> that this is the correct way to fix this problem.

Can you provide a specific example of a (simple) memory map that you
believe causes problems?  It's probably sufficient to give descriptors
for one or two granules (both the descriptor range & type are needed).

Thanks,

	--david

