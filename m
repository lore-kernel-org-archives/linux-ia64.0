From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 25 Oct 2003 06:44:58 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <marc-linux-ia64-106706432406927@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105942507026161@msgid-missing>
In-Reply-To: <marc-linux-ia64-105942507026161@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/to-linus-2.5

This will update the files shown below.

Thanks!

	--david

 arch/ia64/kernel/efi.c       |   26 +++++
 arch/ia64/kernel/gate-data.S |    2 
 arch/ia64/kernel/irq.c       |    2 
 arch/ia64/kernel/module.c    |   82 ++++++++++++++++-
 arch/ia64/kernel/perfmon.c   |  200 +++++++++++++++++++++++++------------------
 arch/ia64/kernel/process.c   |    8 +
 arch/ia64/kernel/unwind_i.h  |    8 -
 include/asm-ia64/io.h        |    3 
 include/asm-ia64/module.h    |    3 
 include/asm-ia64/namei.h     |    2 
 include/asm-ia64/unwind.h    |    6 +
 11 files changed, 240 insertions(+), 102 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (03/10/24 1.1364)
   ia64: Fix/finish kernel module table support so it actually works.

<eranian@hpl.hp.com> (03/10/23 1.1363)
   [PATCH] ia64: fix critical perfmon2 bugs
   
   This patch fixes the following issues:
   
   - fix a nasty corner case by which a task could inherit psr.pp/psr.up
     that could be stale by the time it runs. psr.pp/psr.up bits must be
     cleared on fork and inherited on execve(). Test case provided by
     John Levon.
   
   - mask interrupts when locking the pfm stat structure. We don't want
     to take PMU interrupts in the middle of this kind of critical
     section.
   
   - fix a bug in pfm_close() for context which use asynchronous
     notifications.  You cannot call fasync_helper() with interrupts
     disabled because it reenables them. There was no real danger of
     moving the call outside our critical section.
   
   - fix a bug in in pfm_flush_pmds() where you can leave the freeze bit
     set in the pmc saved state.
   
   - updated dump_pmu_state()
   
   - cleanup the BUG_ON() usage

<arun.sharma@intel.com> (03/10/23 1.1362)
   [PATCH] ia64: fix broken __emul_prefix
   
   his seems to be broken for ia32 on ia64 and possibly other emulation
   architectures as well. The problem comes from
   fs/namei.c:set_fs_altroot() using path_lookup() instead of a
   path_walk() relative to "/" (which is the case for 2.4).

<davidm@tiger.hpl.hp.com> (03/10/23 1.1361)
   ia64: Sync with Linus' i386 patch: Revert bogus IRQ_INPROGRESS clear.

<bjorn.helgaas@hp.com> (03/10/23 1.1360)
   [PATCH] ia64: prevent "dd if=/dev/mem" crash
   
   The drivers/char/mem.c change was accepted, so here's the
   ia64-specific part.

<ianw@gelato.unsw.edu.au> (03/10/22 1.1359)
   [PATCH] ia64: fix gate-data.S build for binutils 2.14
   
   gas will match anything with a prefix
   '.data.' as a data special section.  Thus to stop unnecessary warning
   about changing attributes, we use the .data section standard
   attributes aw when creating gate-data.o.

