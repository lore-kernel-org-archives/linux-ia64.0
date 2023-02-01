From: Mark Rutland <mark.rutland@arm.com>
Date: Wed, 01 Feb 2023 10:50:33 +0000
Subject: Re: [RFC][PATCHSET] VM_FAULT_RETRY fixes
Message-Id: <Y9pD+TMP+/SyfeJm@FVFF77S0Q05N>
List-Id: <linux-ia64.vger.kernel.org>
References: <Y9lz6yk113LmC9SI@ZenIV>
In-Reply-To: <Y9lz6yk113LmC9SI@ZenIV>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Michal Simek <monstr@monstr.eu>, Dinh Nguyen <dinguyen@kernel.org>, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Jan 31, 2023 at 08:02:51PM +0000, Al Viro wrote:
> On x86 it had been noticed and fixed back in 2014, in 26178ec11ef3 "x86:
> mm: consolidate VM_FAULT_RETRY handling".  Some of the other architectures
> had it dealt with later - e.g. arm in 2017, the fix is 746a272e44141
> "ARM: 8692/1: mm: abort uaccess retries upon fatal signal"; xtensa -
> in 2021, the fix is 7b9acbb6aad4f "xtensa: fix uaccess-related livelock
> in do_page_fault", etc.
> 
> However, it never had been done on a bunch of architectures - the
> current mainline still has that bug on alpha, hexagon, itanic, m68k,
> microblaze, nios2, openrisc, parisc, riscv and sparc (both sparc32 and
> sparc64).  Fixes are trivial, but I've no way to test them for most
> of those architectures.

FWIW, when I fixed arm and arm64 back in 2017, I did report the issue here with
a test case (and again in 2021, with maintainers all explciitly Cc'd):

  https://lore.kernel.org/lkml/20170822102527.GA14671@leverpostej/
  https://lore.kernel.org/linux-arch/20210121123140.GD48431@C02TD0UTHF1T.local/

... so if anyone has access to those architectures, that test might be useful
for verifying the fix.

Thanks,
Mark.
