From: Rich Altmaier <richa@engr.sgi.com>
Date: Thu, 22 Mar 2001 17:00:11 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005337@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just a comment in principle, historically in the MIPS compiler we have faced
this trouble.   That is, a conflict between the compiler goal of really good
optimization, and the debugger goal of "mapping runtime object code to
something understood by the source code programmer".
The keener you get on optimizations, the more impossible, and finally
simply impossible, is the debuggers job.   We should appreciate that
we are asking for a stretch from both the optimizer AND the debugger!

When no mapping is possible, do we give up the optimization or the
debugging?   Since the person trying to debug is usually the person
who typed "gcc", they can choose.   One effect is for developers to back
off on optimization levels, except for critical functions.   We see this quite
a lot from our ISVs.   Debug time costs more in "opportunity cost", than
the value of attaining the most optimized code performance.

Thanks, Rich



