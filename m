From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 17 Oct 2003 18:54:09 +0000
Subject: RE: load-store emulation with SIGSEGV
Message-Id: <marc-linux-ia64-106641693501580@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106634457403703@msgid-missing>
In-Reply-To: <marc-linux-ia64-106634457403703@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 17 Oct 2003 11:16:41 -0700, "Jim Hull" <jim.hull@hp.com> said:

  Jim> Matt Chapman wrote:
  >> Yep, I do similar things in a virtual machine that I wrote.
  >> Here are some notes in case you've overlooked some of the finer
  Jim> details
  >> (and perhaps I've overlooked some of the finer details as well :)).

  >> Incrementing the IP:
  sc-> sc_ip += ((sc->sc_ip & 0xf) = 2) ? 0xe : 1;

  Jim> I think there's one scenario where this won't work.  If it's possible
  Jim> for your signal handler to be invoked in cases where the instruction
  Jim> you're trying to skip over is a two-slot "L+X" instruction from an MLX
  Jim> bundle (e.g., movl or brl), then the "slot" bits of sc_ip will be 1,
  Jim> you'll increment them to 2, and when you return to slot 2 of the MLX
  Jim> bundle you'll immediately take an Illegal Instruction fault.

  Jim> Probably most "skip an instruction" signal handlers don't need to worry
  Jim> about this case, because they'll always be pointing at an ordinary
  Jim> single-slot instruction, but it's something to be aware of.

The kernel's ia64_increment_ip() function in arch/ia64/kernel/ptrace.c
could be used as a template here.  Of course, you do need to read the
bundle in order to determine whether it's an MLX template.

	--david
