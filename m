From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 13 Feb 2004 00:47:46 +0000
Subject: Re: [patch] 2.4.25-rc1 Delete redundant ia64_mca_check_errors
Message-Id: <16428.7858.128446.884154@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2539.1076632333@kao2.melbourne.sgi.com>
In-Reply-To: <2539.1076632333@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 13 Feb 2004 11:32:13 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> salinfo automatically processes all record types on all cpus
  Keith> at boot time, ia64_mca_check_errors is now redundant.  This
  Keith> also removes the need for a called_from_init flag on
  Keith> ia64_mca_log_sal_error_record.

The patch fails to apply:

$ patch -p1 -g1 < pp
include/asm-ia64/mca.h 1.16 -> 1.17: 120 lines
patching file include/asm-ia64/mca.h
Hunk #1 succeeded at 114 (offset 3 lines).
arch/ia64/kernel/smpboot.c 1.45 -> 1.46: 612 lines
patching file arch/ia64/kernel/smpboot.c
Hunk #1 succeeded at 306 (offset -43 lines).
can't find file to patch at input line 30
Perhaps you used the wrong -p or --strip option?
The text leading up to this was:
--------------------------
|Index: 25-rc1.10/arch/ia64/kernel/pci.c
|--- 25-rc1.10/arch/ia64/kernel/pci.c Sun, 25 Jan 2004 06:42:02 +1100 kaos (linux-2.4/s/c/0_pci.c 1.1.2.1.3.1.1.2.1.5.1.1.1.2 644)
|+++ 25-rc1.10(w)/arch/ia64/kernel/pci.c Fri, 13 Feb 2004 11:25:50 +1100 kaos (linux-2.4/s/c/0_pci.c 1.1.2.1.3.1.1.2.1.5.1.1.1.2 644)
--------------------------

	--david
