From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 16 Aug 2003 01:20:18 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <marc-linux-ia64-106099683723888@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105942507026161@msgid-missing>
In-Reply-To: <marc-linux-ia64-105942507026161@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

Just a few small fixes/cleanups:

	bk pull http://lia64.bkbits.net/to-linus-2.5

This will update the files shown below.

Thanks!

	--david

 arch/ia64/ia32/sys_ia32.c     |   12 +-
 arch/ia64/kernel/efivars.c    |   98 ++++++++++++++++---
 arch/ia64/kernel/entry.S      |    4 
 arch/ia64/kernel/mca.c        |   11 ++
 include/asm-ia64/sn/nodepda.h |    3 
 include/asm-ia64/unistd.h     |  212 +++++++++++++++++++++++++-----------------
 6 files changed, 232 insertions(+), 108 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (03/08/15 1.1138)
   ia64: Make things compile with gcc-pre3.4 and work on the simulator.

<davidm@tiger.hpl.hp.com> (03/08/15 1.1137)
   entry.S:
     ia64: Fix prologue directives for sys_clone() and sys_clone2()

<bjorn.helgaas@hp.com> (03/08/13 1.1046.562.24)
   [PATCH] ia64: export EFI systab
   
   I know this probably needs to get exported somewhere other than
   /proc, but the rest of efivars is still in /proc and if somebody does
   convert efivars, they might as well do this systab bit at the same
   time.

<bjorn.helgaas@hp.com> (03/08/13 1.1046.562.23)
   [PATCH] ia64: Trivial 2.5 efivars.c whitespace cleanup
   
   Convert leading spaces to tabs.

<peterc@gelato.unsw.edu.au> (03/08/13 1.1046.562.22)
   [PATCH] ia64: Kill warnings in sys_ia32.c
   
   This patch kills compilation warnings in sys_ia32.c.

<davidm@tiger.hpl.hp.com> (03/08/13 1.1046.562.21)
   ia64: Patch by Peter Chubb: Kill _syscallX macros that generate lots of
   warnings, in favour of inline syscalls for clone() and execve(), and direct
   calling of kernel functions for other system calls.

<jbarnes@sgi.com> (03/08/13 1.1046.562.20)
   [PATCH] ia64: is_headless_node fix
   
   Fix is_headless_node() macro to use node_to_cpumask().
