From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 07 Sep 2005 08:00:37 +0000
Subject: RE: [patch] delete sync.i in ia64_switch_to()
Message-Id: <200509070801.j8781Ig25625@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509070723.j877N9g25144@unix-os.sc.intel.com>
In-Reply-To: <200509070723.j877N9g25144@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth wrote on Wednesday, September 07, 2005 12:22 AM
> The sync.i instruction in ia64_switch_to() context switch code
> looks like an old leftover code.  sync.i instruction supposedly
> ensures flush cache operation issued by processor become visible
> to memory reference.  Everywhere I looked where fc instruction is
> used (ia64_fc), a sync.i is always accompanied.  Everywhere in
> the vicinity of context switch (save_switch_stack/load_switch_stack)
> don't have any fc instruction in there.  I don't see any reason why
> we need to issue sync.i in context switch code.  Patch to remove it.

While I'm at it, the reenabling of psr.ic should really belong to dtr
mapping code block. It make the fall through code fast since it doesn't
need to execute the predicated-off instruction.  Logically make more
sense as well since psr.ic was turned off in .map code block.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./arch/ia64/kernel/entry.S.orig	2005-09-07 00:27:54.967615705 -0700
+++ ./arch/ia64/kernel/entry.S	2005-09-07 00:53:36.421698385 -0700
@@ -204,9 +204,6 @@ GLOBAL_ENTRY(ia64_switch_to)
 (p6)	br.cond.dpnt .map
 	;;
 .done:
-(p6)	ssm psr.ic			// if we had to map, reenable the psr.ic bit FIRST!!!
-	;;
-(p6)	srlz.d
 	ld8 sp=[r21]			// load kernel stack pointer of new task
 	mov IA64_KR(CURRENT)=in0	// update "current" application register
 	mov r8=r13			// return pointer to previously running task
@@ -230,6 +227,9 @@ GLOBAL_ENTRY(ia64_switch_to)
 	mov IA64_KR(CURRENT_STACK)=r26	// remember last page we mapped...
 	;;
 	itr.d dtr[r25]=r23		// wire in new mapping...
+	ssm psr.ic			// reenable the psr.ic bit
+	;;
+	srlz.d
 	br.cond.sptk .done
 END(ia64_switch_to)
 

