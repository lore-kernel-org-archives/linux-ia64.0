From: Richard Henderson <rth@twiddle.net>
Date: Tue, 17 Dec 2002 00:25:51 +0000
Subject: [Linux-ia64] Re: ia64 cache flushing?
Message-Id: <marc-linux-ia64-105590709805583@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805582@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805582@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 17, 2002 at 10:22:11AM +1100, Rusty Russell wrote:
> Could someone who is Attuned with the way of ia64 linking and asm
> please look at this?  It's a userspace framework which tests the 2.5
> module code (as modified by RTH to use shared objects rather than
> simple object files).  You can see 9 architectures already done, but
> ia64 doesn't work, for reasons beyond my humble abilities.

This has nothing to do with the icache.  The program crashes
the first time it calls through the PLT, *not* on the first
instruction it executes.

The PLT has been relocated incorrectly.  More in a moment...


r~

