From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 18 Jan 2003 07:41:11 +0000
Subject: Re: [Linux-ia64] [Patch] Fix in unwind.c
Message-Id: <marc-linux-ia64-105590709805728@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805721@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805721@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 17 Jan 2003 17:52:18 -0800, "Siddha, Suresh B" <suresh.b.siddha@intel.com> said:

  Suresh> Current code in unw_create_gate_table() looks like this:
  Suresh> start = (unsigned long) __start_gate_section - segbase; end
  Suresh> = (unsigned long) __stop_gate_section - segbase; size = 0;
  Suresh> first = lookup(&unw.kernel_table, start); for (entry   Suresh> first; entry->start_offset < end; ++entry) size += 3*8 + 8 +
  Suresh> 8*UNW_LENGTH(*(u64 *) (segbase + entry->info_offset));

  Suresh> Code starts with first unwind kernel table entry for the
  Suresh> gate page and goes through all the gate page unwind table
  Suresh> entries. Assume if all the gate page unwind table entries
  Suresh> comes to the end of kernel unwind table(typically this is
  Suresh> what happens because of the order in vmlinux.lds.S), then
  Suresh> there is a chance that we go past beyond the kernel unwind
  Suresh> table and resulting in a fault while we access "segbase +
  Suresh> entry->info_offset".

Yes, I agree that's a bug.  I fixed it in the source code, though
slightly differently from what you had in the patch.

Thanks,

	--david

