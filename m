From: "Donny Cooper" <dcooper@atcc.necsys.com>
Date: Thu, 06 Sep 2001 16:22:54 +0000
Subject: [Linux-ia64] IA64 Linux Kernel Page Sizes
Message-Id: <marc-linux-ia64-105590698805131@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

(1) Below is a previous mail, from David M., responding to page size questions for IA64 kernels.

> As for the future: I'd like to start playing with superpage support
> fairly soon (once I get some spare time on my hands... ;-).  With
> superpages, physically contiguous regions of memory could be mapped
> with a single TLB entry, giving you most of the benefit of (very)
> large page sizes.	--david

Are there any updates on these plans?


(2) Below are current available kernel options (from config).

4KB	For best IA-32 compatibility
8KB   For best IA-64 performance
16KB 	For best IA-64 performance
64KB	Not for Itanium.

What is "IA64 best performance" based on?

We have a large memory system (32GB), and are not concerned with wasting memory during certain benchmarks.  Are 64KB
pages truly not functional on Itanium, or just not recommended because of memory waste.  To my knowledge, HP-UX seems to
benefit from 64KB pages on ITANIUM.

Any input or recommendation on these items is appreciated.


Thanks.
-----------------------------------
Donny Cooper
NEC Systems, Inc.
Advanced Technical Computing Center
dcooper@atcc.necsys.com
www.necservers.com
-----------------------------------


