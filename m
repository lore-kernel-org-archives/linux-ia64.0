From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 21 Mar 2001 08:54:20 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005314@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 20 Mar 2001 23:54:44 -0800, 
David Mosberger <davidm@hpl.hp.com> wrote:
>I also doubt that adding "nop"s in the compiler is the right solution.

After more thought, the problem of attribute ((noreturn)) affects all
architectures, all debuggers and all programs.  It is not just ia64 +
kdb + kernel that has this problem.  An unconditional call to function
F which is declared noreturn is converted by gcc into this

A:
  ...
  call F
X:
  ...

which will cause problems for all debuggers on all architectures.  The
return address is pointing at the start of X but F was really called by
A.

It is not valid to always subtract 1 from the return address because
programmers are allowed to do this in assembler.

A:
  ret = B
  goto F
X:
  ...
B:
  ...

F cannot assume that it was entered via call, it can be entered by any
hand coded construct that gives the same environment as a call, even if
the return is not to the code that branched to F.  Subtracting 1 from
ret in this case would give B-1 which appears to be in X and is wrong.

Given these two methods of entering a function there is no way for a
debugger to adjust the return address correctly in all cases.  Because
the problem case only occurs in C when function F is declared noreturn,
a change to gcc to emit

A:
  ...
  call F
  nop
X:
  ...

if and only if

  (1) F is declared noreturn and
  (2) gcc is discarding the rest of the function that calls F

will fix the problem.  The extra nop is only required to avoid a call
as the very last instruction of a function so it has very little impact
on the size of most programs.  It has zero impact on the speed of the
programs because the nop is never executed, it is just a padding code.


