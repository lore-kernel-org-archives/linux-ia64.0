From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 21 Mar 2001 17:54:47 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005317@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith,

We are dealing with two problems here, both have a solution but the
solutions are conflicting:

 Problem A: "noreturn" optimization confuses kernel unwinder because
	    return address is not inside the caller.

 Solution A: Emit a dummy instruction after the last "br.call" in a
	     "no return" routine.  Downside: requires generating extra
	     code with no purpose other than to make unwinding work

 Problem B: "last-call" type optimizations confuse the gcc unwinder
            because decrementing the return address does not yield
	    an address inside the caller.

 Solution B: Don't decrement return pointer when determining the
	     caller.  Downside: requires that the frame state
	     immediately before and after a br.call is identical.

I agree that manipulating the return pointer seems like a bad idea.
Especially on IA-64 where there is no way of reliably determining
which of the three instruction in a bundle was the one that called a
function.  But generating dummy code just for the purpose of unwinding
doesn't seem 100% right either, as the unwind convention were
expressedly designed to work with fully optimized code.

Anyhow, I'll re-read the unwind conventions when I'm back at work.
Either the document answers this question unambigiously and one of the
existing unwinder implementation is wrong, or it doesn't answer the
question, in which case we need to pick one solution and work towards
clarifying this point in the manual.

	--david

>>>>> On Wed, 21 Mar 2001 19:54:20 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> On Tue, 20 Mar 2001 23:54:44 -0800, David Mosberger
  Keith> <davidm@hpl.hp.com> wrote:
  >> I also doubt that adding "nop"s in the compiler is the right
  >> solution.

  Keith> After more thought, the problem of attribute ((noreturn))
  Keith> affects all architectures, all debuggers and all programs.
  Keith> It is not just ia64 + kdb + kernel that has this problem.  An
  Keith> unconditional call to function F which is declared noreturn
  Keith> is converted by gcc into this

  Keith> A: ...  call F X: ...

  Keith> which will cause problems for all debuggers on all
  Keith> architectures.  The return address is pointing at the start
  Keith> of X but F was really called by A.

  Keith> It is not valid to always subtract 1 from the return address
  Keith> because programmers are allowed to do this in assembler.

  Keith> A: ret = B goto F X: ...  B: ...

  Keith> F cannot assume that it was entered via call, it can be
  Keith> entered by any hand coded construct that gives the same
  Keith> environment as a call, even if the return is not to the code
  Keith> that branched to F.  Subtracting 1 from ret in this case
  Keith> would give B-1 which appears to be in X and is wrong.

  Keith> Given these two methods of entering a function there is no
  Keith> way for a debugger to adjust the return address correctly in
  Keith> all cases.  Because the problem case only occurs in C when
  Keith> function F is declared noreturn, a change to gcc to emit

  Keith> A: ...  call F nop X: ...

  Keith> if and only if

  Keith>   (1) F is declared noreturn and (2) gcc is discarding the
  Keith> rest of the function that calls F

  Keith> will fix the problem.  The extra nop is only required to
  Keith> avoid a call as the very last instruction of a function so it
  Keith> has very little impact on the size of most programs.  It has
  Keith> zero impact on the speed of the programs because the nop is
  Keith> never executed, it is just a padding code.

