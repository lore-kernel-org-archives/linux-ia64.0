From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 14 Dec 2000 04:39:17 +0000
Subject: Re: [Linux-ia64] switch_stack position
Message-Id: <marc-linux-ia64-105590678205830@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205821@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205821@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Dec 2000 14:46:20 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> On Wed, 13 Dec 2000 18:56:21 -0800, David Mosberger
  Keith> <davidm@hpl.hp.com> wrote:
  >>>>>>> On Wed, 13 Dec 2000 16:03:17 +1100, Keith Owens
  >>>>>>> <kaos@melbourne.sgi.com> said:
  Keith> I am adding support for separate pt_regs and switch_stack by
  Keith> adding struct switch_stack *sw; to struct thread and struct
  Keith> switch_stack *prev_sw; to struct switch_stack.
  Keith> DO_SAVE_SWITCH_STACK and DO_LOAD_SWITCH_STACK track the
  Keith> position of the last switch_stack (LIFO), copy_thread sets
  Keith> prev_sw to NULL for a new process.
  >>  Ouch.

  Keith> No big deal.  5 new instructions (1 extra bundle) in
  Keith> save_switch_stack, 3 new instructions (no extra bundles) in
  Keith> load_switch_stack.  One assignment to 0 in copy_thread().
  Keith> Plus one __u64 in struct switch_stack.

The "Ouch" was meant as in "over my dead body". ;-)

  Keith> The problem is anything that wants to look at other processes
  Keith> on SMP; kdb and get_wchan are two examples.  Currently kdb
  Keith> assumes that any process which is not current on _this_ cpu
  Keith> is blocked.  But the process could be running on another cpu.
  Keith> kdb needs a safe way of getting the last switch_stack for any
  Keith> process or of determining that the process has no
  Keith> switch_stack and therefore cannot be reported.

Note that the unwind code is written such that it cannot fault, even
if the initial state on the stack is completely bogus.  This is why
it's safe to call get_wchan() on a process that's running.

	--david

