From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 26 Mar 2004 00:52:00 +0000
Subject: Re: In-Kernel NaT consumption trap when debugging highly-parallel
Message-Id: <16483.32432.235372.587515@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16482.12999.250663.921106@wombat.chubb.wattle.id.au>
In-Reply-To: <16482.12999.250663.921106@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 25 Mar 2004 12:15:51 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Hi, I'm trying to debug a highly-threaded user-space program,
  Peter> but gdb is triggering NaT consumption faults in the middle of
  Peter> ptrace.

The attached patch should fix it.  Bjorn, I think the same will be needed
for 2.4.

It appears that the combination of gdb 6.x and NPTL is triggering this
bug (which has been there forever).  What happened is that gdb was
trying to read r4 in a task that was in the middle of a clone2().
clone2() spills that register (via SAVE_SWITCH_STACK) along with the
(primary) UNaT.  Unfortunately, the typo in run_script() which is
fixed by the patch below caused the primary-UNaT address to be
calculated as 0, which would then cause the NULL-pointer dereference.

	--david

=== arch/ia64/kernel/unwind.c 1.37 vs edited ==--- 1.37/arch/ia64/kernel/unwind.c	Thu Feb 19 11:27:59 2004
+++ edited/arch/ia64/kernel/unwind.c	Thu Mar 25 16:34:00 2004
@@ -1746,7 +1746,7 @@
 			if (!state->pri_unat_loc)
 				state->pri_unat_loc = &state->sw->ar_unat;
 			/* register off. is a multiple of 8, so the least 3 bits (type) are 0 */
-			s[dst+1] = (*state->pri_unat_loc - s[dst]) | UNW_NAT_MEMSTK;
+			s[dst+1] = ((unsigned long) state->pri_unat_loc - s[dst]) | UNW_NAT_MEMSTK;
 			break;
 
 		      case UNW_INSN_SETNAT_TYPE:
