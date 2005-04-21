From: tony.luck@intel.com
Date: Thu, 21 Apr 2005 20:42:49 +0000
Subject: ia64 git pull
Message-Id: <200504212042.j3LKgng04318@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Linus,

First ia64 change is sitting in a GIT repository at:

	http://www.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git

Please pull (and comment if anything is wrong, or could be improved ... e.g.
what's the easiest way to name the repository for you to cut&paste?)

-Tony

Diffstat:

 include/asm-ia64/bitops.h     |   21 +++++++++++++++++----
 include/asm-ia64/gcc_intrin.h |   10 +++++++---
 2 files changed, 24 insertions(+), 7 deletions(-)

Changesets:

tree 2179380ee3eb38fb393719e6ce32b15e934c4a44
parent d8470b7c13e11c18cf14a7e3180f0b00e715e4f0
author David Mosberger-Tang <davidm@hpl.hp.com> 1114106879 -0700
committer Tony Luck <tony.luck@intel.com> 1114106879 -0700

[IA64] fix fls()

The ia64-version of fls() never worked as intended (the bitnumbering
was off by 1 and fls(0) was undefined).  This patch fixes the problem
by using a popcnt-based fls(), which on McKinley-derived cores is
slightly faster than both ia64_fls() and generic_fls().  The resulting
code, however, is bigger (7-8 bundles instead of about 3 bundles).
Also switch ia64_popcnt() to __builtin_popcountl() for GCC v3.4 or
newer since the compiler can predicate that and schedule it better.

Thanks to Simon Derr and Matt Mackall for tracking down this bug.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>
