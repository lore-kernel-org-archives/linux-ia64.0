From: Jim Wilson <wilson@specifixinc.com>
Date: Fri, 16 Jul 2004 20:02:03 +0000
Subject: Re: problem with ski & NUE
Message-Id: <1090008123.1093.11.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040715133007.46413.qmail@web14205.mail.yahoo.com>
In-Reply-To: <20040715133007.46413.qmail@web14205.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2004-07-16 at 00:27, Daniele Velardi wrote:
> on my OS is already installed glibc 2.3.2 (suse 9.0)!

Then I don't know what the problem.

The problem is clearly not that your OS is too old.  Perhaps the problem
is that the OS is too new then, or perhaps that you are using suse and
the ski binary was compiled under Red Hat Linux.  The nue release you
are using is 3 years old, a lot of things have changed since then.

I haven't used ski in a long time, and there are probably not many other
people still using it, so you may have trouble finding more useful help.

You might try running ldd on the ski binary to see what libraries it has
been linked against, and to check if those libraries are present on your
system.

> My installation procedure is correct?

I don't know.

> Then for the system mode, i have tried to boot ski
> bootoloader vmlinux, it is correct or i have to
> recompilte all for my machine?

I don't know.

> The DW_FORM_strp error result with gcc v 2.96 and then
> also with gcc3 (form nue-gcc3-010625.tar.gz) and with
> the as v2.13 (gas-030124.tar.gz). it 's all ok?

You need compatible bfds in the generator (as/ld) and the reader (ski). 
Since ski is only available as a binary, and a fairly old one, that
implies that you will have to use an old gcc and binutils releases to be
compatible with it.  Using an old as isn't enough, you need both an old
as and ld.

However, this is all speculation.  You may have to spend some time
investigating these problems yourself.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com

