From: Keith Owens <kaos@sgi.com>
Date: Thu, 10 Feb 2005 02:47:47 +0000
Subject: Re: Make MCA stack look like a normal kernel stack
Message-Id: <12952.1108003667@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <10372.1107999173@kao2.melbourne.sgi.com>
In-Reply-To: <10372.1107999173@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 9 Feb 2005 18:26:37 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Thu, 10 Feb 2005 12:32:53 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> I have a long term aim to make the MCA and INIT stacks look
>  Keith> like normal process stacks
>
>That would indeed simplify life for the unwinder a bit, though it's
>not strictly needed.  Alternatively, it might be possible to define
>the proc_state_dump area as yet another special frame.  I would prefer
>if this can be avoided, though.

<aol>Me too</aol>.  The problem is not just the kernel unwinder, it is
ia64 unwind code in general, including gdb, lcrash and other dump
diagnosis tools.  All those unwinders would need to be updated to
define proc_state_dump.  No thanks.

>  Keith> * MCA stack in struct ia64_mca_cpu looks like a normal kernel stack,
>  Keith> * except that the rse_stack and proc_state_dump are stored at the
>  Keith> * top of the MCA stack.  All entries are 16 byte aligned.
>  Keith> *
>  Keith> *      +---------------------------+
>  Keith> *      |       RSE stack frame     |
>  Keith> *      +---------------------------+
>  Keith> *      |       proc_state_dump     |
>  Keith> *      +---------------------------+
>  Keith> *      |           pt_regs         |
>  Keith> *      +---------------------------+
>  Keith> *      |    16 byte scratch area   |
>  Keith> *      +---------------------------+ <-- SP at start of C MCA handler
>  Keith> *      |           .....           |
>  Keith> *      +---------------------------+
>  Keith> *      |    RBS for MCA handler    |
>  Keith> *      +---------------------------+
>  Keith> *      | struct task, not used yet |
>  Keith> *      +---------------------------+ <-- Bottom of MCA stack
>
>Hmmh, I don't understand why "RSE stack frame" is at the
>highest-address-end of the stack.  Why not make it part of the RBS, as
>is normally done?

As I said in my mail, RSE stack frame needs more work.  In the current
kernel it is a separate area with its own format.  I just collapsed
that area into the MCA stack, preserving the format.  Eventually it
will be part of the RBS, once I work out what format the unwinder
requires.

The problem is that some of the dirty registers will be in the original
stack, some will be in the MCA stack.  It may be easier to copy the
dirty registers from the MCA stack to the previous stack in the
MCA/INIT handlers, rather than handling it in the unwinder.  WIP.

>Also, I'd hope that proc_state_dump isn't needed as part of the
>task-structure: we should be able to store part of its contents in
>pt_regs

I agree.  This is a first cut at consolidating the existing data areas,
with minimal code changes.  As I start testing the unwind support,
pt_regs will replace most, if not all, of proc_state_dump.  That
requires much more intrusive code changes.

>and the rest should be loaded into the preserved registers
>before calling the first C routine.  No?

The preserved registers at the time of MCA/INIT still need to be saved
so they can be restored on return to SAL.  Save the preserved
registers, set the values that the kernel needs, call C code, restore
original preserved registers, return to SAL.  Hmm, I just described
struct switch_stack, didn't I?

