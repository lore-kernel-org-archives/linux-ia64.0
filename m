From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 17 Jul 2003 18:09:50 +0000
Subject: RE: [PATCH] remove pa->va->pa conversion for efi.acpi
Message-Id: <marc-linux-ia64-105846541211987@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105797540229907@msgid-missing>
In-Reply-To: <marc-linux-ia64-105797540229907@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 17 Jul 2003 10:43:19 -0700, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com> said:

  >> Does ACPI really guarantee that the table is never stored at physical
  >> address 0?  If not, then leaving it as a virtual address might be
  >> safer.  (Yes, I know it's very unlikely for today's system, but at
  >> least on ia64, pfn 0 is normal RAM so it seems at least in principle
  >> possible to store the ACPI table there).

  Matthew> No guarantee that I could find...I suppose this is
  Matthew> technically possible. :) However, considering the ACPI
  Matthew> routines expect a physical address and thus immediately map
  Matthew> it to get the descriptor (either directly with virt_to_phys
  Matthew> or via ioremap), this seems redundant.  Given the mapping
  Matthew> scheme employed, is this still risky?  I'd like to reuse
  Matthew> the same code path for ia32, but don't want to break ia64.

Note that I'm only pointing this out because I thought there were some
NULL-pointer checks.  If it's a physical address, 0 is a valid
address.  If it's an (identity-mapped) kernel address, NULL-pointer
checks are OK.

	--david
