From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 Nov 2003 22:12:40 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <marc-linux-ia64-106945277508083@msgid-missing>
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

 arch/ia64/ia32/ia32_signal.c |    3 +++
 arch/ia64/kernel/patch.c     |    2 +-
 arch/ia64/kernel/signal.c    |    6 +++---
 arch/ia64/kernel/traps.c     |    6 ++----
 4 files changed, 9 insertions(+), 8 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (03/11/21 1.1366)
   ia64: Drop printk from ia64_ni_syscall().  This is a temporary fix
   	for 2.6.0.  The proper fix is to replace ia64_ni_syscall with
   	sys_ni_syscall, but that would make the patch quite large, so
   	we defer that till 2.6.1.

<davidm@tiger.hpl.hp.com> (03/11/21 1.1365)
   ia64: From Linus/Paulus: reset restart_block function in
   	restore_sigcontext().  Also update ia32 subsystem accordingly.

<davidm@tiger.hpl.hp.com> (03/11/21 1.1364)
   ia64: Fix off-by-1 error in imm60 patching.  The bug hasn't been observed
   	in practice, but it's clearly wrong and just waiting there to
   	get triggered...
