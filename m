From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 17 Oct 2003 15:34:20 +0000
Subject: Re: load-store emulation with SIGSEGV (gate.S bug?)
Message-Id: <marc-linux-ia64-106640599821262@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106640456919155@msgid-missing>
In-Reply-To: <marc-linux-ia64-106640456919155@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 17 Oct 2003 15:26:13 -0000, 
Jeffrey William Lake <lakes@lakes.plus.com> wrote:
>After some investigation I discovered that a "flushrs" at the start of my
>signal handler cured the problem.
>
>Looking at "arch/ia64/kernel/gate.S" revealed that a "cover" is used to
>get the registers onto the backing store (commented as such several
>times), but by my understanding there is enough scope from the instruction
>description that they may be cached.

cover only marks the current frame (r32+) as dirty.  It does not write
the dirty registers out to backing store, that is left to RSE to do at
its leisure.  flushrs forces RSE to write the dirty registers out to
memory.

>Therefore, should gate.S include a
>"flushrs" as well or, for performance reasons be left for the user to
>decide?

Probably best left for the user to decide.  The majority of signal
handlers will not require the registers to be flushed.

