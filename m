From: Roman Zippel <zippel@linux-m68k.org>
Date: Fri, 16 Feb 2007 19:12:57 +0000
Subject: Re: Kconfig bug (was: Re: fault-injection framework on ia64)
Message-Id: <Pine.LNX.4.64.0702162003380.14457@scrub.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <200702161938.17340.blaisorblade@yahoo.it>
In-Reply-To: <200702161938.17340.blaisorblade@yahoo.it>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On Fri, 16 Feb 2007, Blaisorblade wrote:

> However, more important, if I remove STACKTRACE_SUPPORT, or if I make 
> it 'default n', FAULT_INJECTION can still be enabled, even if it selects 
> STACKTRACE which has a failed dependency (tested on UML). Which is a Kconfig 
> bug - if A selects B and B depends on C, no dependency of A on C is deduced. 
> Right Roman?

Correct, but could someone please give me some more context, what the bug 
is supposed to be here?

bye, Roman
