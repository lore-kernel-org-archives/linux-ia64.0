From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Feb 2005 02:26:37 +0000
Subject: Re: Make MCA stack look like a normal kernel stack
Message-Id: <16906.50781.867221.701264@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <10372.1107999173@kao2.melbourne.sgi.com>
In-Reply-To: <10372.1107999173@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 10 Feb 2005 12:32:53 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> I have a long term aim to make the MCA and INIT stacks look
  Keith> like normal process stacks

That would indeed simplify life for the unwinder a bit, though it's
not strictly needed.  Alternatively, it might be possible to define
the proc_state_dump area as yet another special frame.  I would prefer
if this can be avoided, though.

  Keith> * MCA stack in struct ia64_mca_cpu looks like a normal kernel stack,
  Keith> * except that the rse_stack and proc_state_dump are stored at the
  Keith> * top of the MCA stack.  All entries are 16 byte aligned.
  Keith> *
  Keith> *      +---------------------------+
  Keith> *      |       RSE stack frame     |
  Keith> *      +---------------------------+
  Keith> *      |       proc_state_dump     |
  Keith> *      +---------------------------+
  Keith> *      |           pt_regs         |
  Keith> *      +---------------------------+
  Keith> *      |    16 byte scratch area   |
  Keith> *      +---------------------------+ <-- SP at start of C MCA handler
  Keith> *      |           .....           |
  Keith> *      +---------------------------+
  Keith> *      |    RBS for MCA handler    |
  Keith> *      +---------------------------+
  Keith> *      | struct task, not used yet |
  Keith> *      +---------------------------+ <-- Bottom of MCA stack

Hmmh, I don't understand why "RSE stack frame" is at the
highest-address-end of the stack.  Why not make it part of the RBS, as
is normally done?

Also, I'd hope that proc_state_dump isn't needed as part of the
task-structure: we should be able to store part of its contents in
pt_regs and the rest should be loaded into the preserved registers
before calling the first C routine.  No?

	--david
