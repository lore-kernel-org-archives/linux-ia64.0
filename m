From: Richard Henderson <rth@twiddle.net>
Date: Tue, 17 Dec 2002 03:42:51 +0000
Subject: [Linux-ia64] Re: ia64 cache flushing?
Message-Id: <marc-linux-ia64-105590709805594@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805582@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805582@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 16, 2002 at 06:15:28PM -0800, David Mosberger wrote:
> For someone who cares about modules and ia64 performance: you might
> want to consider to use "brl" in the PLT stub instead of the
> standardized code sequence.

You'll have to figure out how to find the plt stub though.
It's not marked in any way.  The only thing you get a pointer
to is the .IA_64.pltoff entry.

For userland, the .plt stub has to use an indirect branch
because the first invocation goes through the dynamic linker.
Then we update the .pltoff entry and so subsequent calls go
direct to the target.


r~

