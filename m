From: Jim Wilson <wilson@redhat.com>
Date: Thu, 30 Jan 2003 16:08:20 +0000
Subject: Re: [Linux-ia64] segv with gas using gcc 3.2
Message-Id: <marc-linux-ia64-105590709805779@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805767@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805767@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It isn't clear to me what you are doing, since you mention problems with
compiler optimization, but then state that you are using asm macros instead
of gcc extended asm statements.  You can't use asm macros in C code, so I
don't understand what you are trying to say.

Gcc has support for automatically moving rarely used sections of code out
of line.  You can use __builtin_expect in a condition to indicate whether
it is expected to be true or false.  When gcc sees that a section of code
is not expected to be executed, then it tries to move it someplace out of
the way.  This happens in the block reordering pass.  This might be a better
solution that what you are doing now.  This is used in various places if you
want to see examples.  I think it is used in the kernel and glibc.  There is
also a little info in the gcc documentation.

On IA-64, changing sections in the middle of the function is a very bad idea.
In addition to the unwind problems that David mentioned, you will also get
bad insn bundling (unnecessary nops and stop bits).  You may also get bad
debug info.  I think the IA-64 assembler should emit an error if someone
switches sections in the middle of a function, but I never got a chance to
try to implement that.

Jim

