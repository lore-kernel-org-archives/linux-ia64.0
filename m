From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 30 Jan 2002 21:57:33 +0000
Subject: Re: [Linux-ia64] What's taking all the system time..?
Message-Id: <marc-linux-ia64-105590698805966@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805950@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805950@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>/tmp/ccC11dFe.s:15538: Error: Unknown opcode `data16.ua @iplt

You need a newer binutils if you want to use gcc 3.0.[23] to compile C++ code.

New IA-64 assembler syntax was introduced last summer, because it was not
possible to fully implement the C++ ABI with the original assembler syntax.
This new assembler syntax is used starting with gcc 3.0.2, and is not supported
by any binutils older that last summer.  That unfortunately means that binutils
2.11 is not new enough, you have to use an unreleased binutils from the FSF
development source tree.

Jim

