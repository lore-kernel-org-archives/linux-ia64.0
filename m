From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 11 Nov 2003 07:33:04 +0000
Subject: RE: Problem with accessing page tables
Message-Id: <marc-linux-ia64-106853600011735@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106826502101883@msgid-missing>
In-Reply-To: <marc-linux-ia64-106826502101883@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 11 Nov 2003 10:32:42 +0530, "Ameya Mitragotri" <ameya.mitragotri@wipro.com> said:

  Ameya> Our assumption is that the addresses for the global variables
  Ameya> will surely be allocated.  (e.g. &panic_timeout should always
  Ameya> resolve to an available PGD,PMD,PTE and in the end to a
  Ameya> page.)

Nope, that's a bad assumption.  The kernel's page-table is strictly
needed only for vmalloc'd memory.  Whether or not it's used to map the
kernel itself, is architecture-specific.  In the case of ia64, we use
an identity-mapping for kernel memory (the kernel itself is pinned
into the data TLB), so no page-tables are used.

  Ameya> The whole purpose of this being, We want to simulate the page
  Ameya> tables at user level to analyse a crash dump (LKCD) on
  Ameya> IA64. So we dump the page tables and when Lcrash (the user
  Ameya> mode tool for analysing dumps) reads this dump, it can seek
  Ameya> the page tables and access global variables accordingly. This
  Ameya> also will help us eventually in unwinding the dumped stack.

In the 2.6 kernel, the kernel image is pinned into the D TLB at
address 0xa000000100000000.  This _usually_ maps to physical address
64MB, but under certain circumstances (e.g., lack of memory at 64MB,
kernel image replication for better NUMA-locality), it may map to some
other physical address.

	--david
