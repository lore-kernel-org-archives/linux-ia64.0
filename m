From: "stephane eranian" <eranian@googlemail.com>
Date: Wed, 30 Jul 2008 22:31:36 +0000
Subject: 2.6.26 new perfmon kernel patch + libpfm + pfmon available
Message-Id: <7c86c4470807301531i232ebd44m869affe95f036484@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <7c86c4470807301530s224f5104wdd5004419464bc2e@mail.gmail.com>
In-Reply-To: <7c86c4470807301530s224f5104wdd5004419464bc2e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: ia64 <linux-ia64@vger.kernel.org>

Hello,

I have released the perfmon2 kernel patch for kernel v2.6.26. There is
no new major features.  Concerning the merge with mainline, we use a different
code base which contains only code to  supports only per-thread counting on
X86 processors. The patch is distributed as a quilt patchset and is
posted on LKML.

Here are some of the kernel changes:
 - Support for Intel architectural perfmon v3 (as per IA-32 Vol3b June 2008)
 - base syscall exported in /sys/kernel/perfmon/syscall
 - experimental utrace support
 - added dep_pmcs[] to PMD definitions to avoid picking up stale config
 - important IBM Power updates to solve counter overflow issues (Corey Ashford)
 - AMD64 APIC/PCI cleanups for IBS support (Robert Richter)
 - new API for handler routine of sampling formats to accomodate IBM
Cell (Carl Love)

There is also a new release for libpfm, now at version 3.5.
The changes include:
 - support for AMD K7 (Vince Weaver)
 - support for Intel architectural perfmon v3
 - support for SiCortex (ICA9A, ICA9B) (Phil Mucci)
 - dynamic perfmon syscall support via /sys
 - new environment variable to control debugging and force particular PMU model

Finally, a new major version of pfmon, now at pfmon-3.5 with some minor
changes:
 - group unknown symbols as UNKNOWN when sampling (Andrzej Nowak)
 - lots of bug fixes

As usual all files and more detailed changelogs can be downloaded from our
website at:

       http://perfmon2.sourceforge.net

Enjoy,
