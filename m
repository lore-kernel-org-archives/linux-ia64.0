From: Piet/Pete Delaney <piet@sgi.com>
Date: Wed, 30 Jan 2002 22:37:20 +0000
Subject: [Linux-ia64] Updating to the latest binutils - any tips on how to do it easily?
Message-Id: <marc-linux-ia64-105590698805968@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 30, 2002 at 01:57:33PM -0800, Jim Wilson wrote:
> >/tmp/ccC11dFe.s:15538: Error: Unknown opcode `data16.ua @iplt
> 
> You need a newer binutils if you want to use gcc 3.0.[23] to compile C++ code.
> 
> New IA-64 assembler syntax was introduced last summer, because it was not
> possible to fully implement the C++ ABI with the original assembler syntax.
> This new assembler syntax is used starting with gcc 3.0.2, and is not supported
> by any binutils older that last summer.  That unfortunately means that binutils
> 2.11 is not new enough, you have to use an unreleased binutils from the FSF
> development source tree.
> 
> Jim

Any suggestions on installing a newer binutils? I tried installing 
a recient version (binutils-2.11.2 or binutils-2.10.1) to /usr/local
and had problems with commands compiled with the current compiler,
(egcs-2.91.66/(egcs-1.1.2 release)), getting a SEGV when they started; 
so I backed out the changed binutils installation for now.

Perhaps the compiler and binutils have to be changed together?

The newer binutils seems to be needed for our LKCD lcrash stuff to work 
corectly for disassembling ia64 code.

-piet

