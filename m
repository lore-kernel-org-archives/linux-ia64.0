From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 31 Aug 2007 04:50:52 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <alpine.LFD.0.999.0708302146150.25853@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Thu, 30 Aug 2007, Luck, Tony wrote:
> 
> This will update the files shown below.  The change to drivers/char/hpet.c
> makes the hpet timer code there ia64 only until we can do something better
> to merge in arch/{i386,x86_64)/kernel/hpet.c

That's crazy. The patch in question looks like this:

	+/* XXX - FIXME: i386, x86_64 and ia64 all have separate
	+ * hpet clocksource implementations. They should be merged
	+ * and this would be a good place for it.
	+ * Right now this is ia64 only.
	+ */
	+#ifdef CONFIG_IA64
	 static struct clocksource *hpet_clocksource;
	+#else /* this isn't generic enough to use for everyone yet */
	+static struct clocksource *hpet_clocksource = (struct clocksource*)0xdead;
	+#endif

and that means that the change in that patch affects everybody *but* 
ia64 if I read that right.

I do *not* want to take a patch from the ia64 tree that by definition only 
matters for non-ia64 machines. 

So there are two cases:

 - either the code is already only used on ia64, and nobody else will 
   care.

   In this case, the patch is pointless.

 - or it's used by others, and others *will* care, and (judging by the 
   probably intent of the bogus initializer) they may then die a horrible 
   death.

   In this case, the patch is actively evil, and should not have come in 
   through an ia64 merge.

In other words, either it's pointless, or it's really really bad. Please 
explain to me why I should pull this, especially this late in the -rc 
game?

		Linus
