From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 06 Jan 2001 00:51:17 +0000
Subject: Re: [Linux-ia64] Incorrect unwind data in entry.S
Message-Id: <marc-linux-ia64-105590678205891@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205870@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205870@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 5 Jan 2001 10:48:45 -0800, 
David Mosberger <davidm@hpl.hp.com> wrote:
>>>>>> On Thu, 21 Dec 2000 14:42:45 +1100, Keith Owens <kaos@ocs.com.au> said:
>
>  Keith> The prologue after .ret21 makes no sense.  Unwind claims that
>  Keith> we are increasing the stack by 416 and spilling registers to
>  Keith> stack but we are really removing the struct switch_stack.
>
>The code is correct.  A prologue always describes the _current state_
>of the frame, not the _changes_ to the frame (which would make no
>sense).  In other words, the code says that after the
>load_switch_stack, the frame is back to the original state (switch
>stack is gone).

Where does it say that a prologue always describes the current state?
I am looking at Intel's IA-64 Software Conventions and Runtime
Architecture Guide, 24535802.pdf, August 2000.  Section 11.3

  "For the purposes of unwinding, we divide every procedure up into one
  or more regions, which are classified as either "prologue" or "body"
  regions."

  ...

  "For both types of regions, the unwinder needs to know the state of
  the stack frames and preserved registers upon entry to the region.
  There are four ways to establish the entry state for an unwind
  region:

  * The first region in the procedure assumes that both stack frames
    are unallocated, and no registers have been saved upon entry to the
    region.
  * A region may modify the state of the stack frames and preserved
    registers; each subsequent region takes the previous region's exit
    state as its entry state.
  * When control does not flow into a region from directly above it,
    the region may specify an alternate predecessor region whose exit
    state is used instead.
  * Zero-length prologue regions may be inserted just prior to a
    prologue or body region to set up the correct entry state."

The first region in a procedure has no initial state, so the first
prologue must describe the current state, we agree on that.  The second
point explicitly says that "each subsequent region takes the previous
region's exit state as its entry state", this point makes no
distinction between body and prologue regions.

According to the docs, a second prologue in a procedure should only
modify the existing state, not define the entire state.  Either the
documentation is incorrect or the unwind data for the second prologue
in ia64_prepare_handle_unaligned is incorrect.


