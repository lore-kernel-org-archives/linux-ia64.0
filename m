From: Blaisorblade <blaisorblade@yahoo.it>
Date: Fri, 16 Feb 2007 20:10:42 +0000
Subject: Re: Kconfig bug (was: Re: fault-injection framework on ia64)
Message-Id: <200702162110.42608.blaisorblade@yahoo.it>
List-Id: <linux-ia64.vger.kernel.org>
References: <200702161938.17340.blaisorblade@yahoo.it>
In-Reply-To: <200702161938.17340.blaisorblade@yahoo.it>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 16 February 2007 20:12, Roman Zippel wrote:
> Hi,
>
> On Fri, 16 Feb 2007, Blaisorblade wrote:
> > However, more important, if I remove STACKTRACE_SUPPORT, or if I make
> > it 'default n', FAULT_INJECTION can still be enabled, even if it selects
> > STACKTRACE which has a failed dependency (tested on UML). Which is a
> > Kconfig bug - if A selects B and B depends on C, no dependency of A on C
> > is deduced. Right Roman?
>
> Correct, but could someone please give me some more context, what the bug
> is supposed to be here?
Hmm.
You agree that "if A selects B and B depends on C, no dependency of A on C is 
deduced", right?

The implication is that the user can enable A, which selects B, while C is 
still disabled. The B -> C dependency is violated, and the build will fail or 
bad things will happen.

I hope things are now clearer, even without the description of the testcase 
where this happened.
-- 
Inform me of my mistakes, so I can add them to my list!
Paolo Giarrusso, aka Blaisorblade
http://www.user-mode-linux.org/~blaisorblade
Chiacchiera con i tuoi amici in tempo reale! 
 http://it.yahoo.com/mail_it/foot/*http://it.messenger.yahoo.com 
