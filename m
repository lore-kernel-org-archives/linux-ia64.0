From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 18 Jul 2000 18:13:28 +0000
Subject: Re: [Linux-ia64] gcc/as problem: integer operand out of range
Message-Id: <marc-linux-ia64-105590678205206@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205202@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205202@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	iaxxsldc.S: Assembler messages:

If the compiler generated this instruction, then the compiler is at fault.

However, it looks like you are compiling a hand-written assembly file, because
the filename in the error message ends in .S.  The only way that can happen
is if you feed an assembly file to the compiler.  In this case, the error would
be in the hand-written assembly language code.

Jim


