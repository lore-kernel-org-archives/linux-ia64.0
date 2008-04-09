From: Petr Tesarik <ptesarik@suse.cz>
Date: Wed, 09 Apr 2008 12:57:04 +0000
Subject: Re: [PATCH 2/4] set_restore_sigmask TIF_SIGPENDING
Message-Id: <1207745824.8604.16.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain>
	 <20080329001341.7F93826FA1D@magilla.localdomain>
	 <alpine.LFD.1.00.0803281746480.14670@woody.linux-foundation.org>
	 <20080408113519.GA227@tv-sign.ru>
	 <1207739787.27048.57.camel@shinybook.infradead.org>
	 <20080409113939.GA99@tv-sign.ru>
In-Reply-To: <20080409113939.GA99@tv-sign.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Nesterov <oleg@tv-sign.ru>
Cc: David Woodhouse <dwmw2@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Roland McGrath <roland@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 2008-04-09 at 15:39 +0400, Oleg Nesterov wrote:
> On 04/09, David Woodhouse wrote:
> >
> > On Tue, 2008-04-08 at 15:35 +0400, Oleg Nesterov wrote:
> > > Why do we need any flag? It looks a bit ugly. Isn't it better to introduce
> > > the new magic ERESTART_XXX which means ERESTARTNOHAND + restore-sigmask ?
> > > 
> > > We only need this flag as an implicit parameter to the arch dependent do_signal()
> > > which we can't call directly, and thus it must imply TIF_SIGPENDING, and it
> > > is not valid after do_signal() (should be cleared). This all looks like
> > > ERESTART_ magic, why should we add something else ?
> > > 
> > > See also http://marc.info/?l=linux-kernel&m3734458516136
> > > 
> > > Of course, probably it is too late to change the implementation even if
> > > I am right, the question is: what I am missed?
> > 
> > Q: When ppoll() is interrupted by a signal, what signal mask should be
> > active when the signal handler is active?
> > 
> > I believe that the signal handler should run with the temporary sigmask
> > which was set by ppoll(), and the original sigmask should be restored
> > only when the handler completes -- and that's what we achieve with
> > TIF_RESTORE_SIGMASK.
> 
> Yes sure.
> 
> > So a signal which was originally enabled but is temporarily disabled by
> > the mask passed to ppoll() will not be able to interrupt the handler for
> > the signal which interrupted ppoll().
> > 
> > Your version will restore the original signal mask _before_ invoking the
> > signal handler which interrupted ppoll()
> 
> Why do you think so?
> 
> Please look at the "patch" below,
> 
> 	--- arch/x86/kernel/signal_32.c	2008-02-15 16:58:38.000000000 +0300
> 	+++ -	2008-04-09 15:16:05.393510662 +0400
> 	@@ -526,10 +526,14 @@ handle_signal(unsigned long sig, siginfo
> 	 {
> 		int ret;
> 	 
> 	+	oldset = &current->blocked;
> 	+
> 		/* Are we from a system call? */
> 		if (regs->orig_ax >= 0) {
> 			/* If so, check system call restarting.. */
> 			switch (regs->ax) {
> 	+			case -ERESTART_XXX:
> 	+				oldset = &current->saved_sigmask;
> 				case -ERESTART_RESTARTBLOCK:
> 				case -ERESTARTNOHAND:
> 					regs->ax = -EINTR;
> 
> We also need a similar change in do_signal(). Now,
> 
> 	--- fs/select.c	2008-02-15 16:59:15.000000000 +0300
> 	+++ -	2008-04-09 15:19:29.015991911 +0400
> 	@@ -805,9 +805,8 @@ asmlinkage long sys_ppoll(struct pollfd 
> 			if (sigmask) {
> 				memcpy(&current->saved_sigmask, &sigsaved,
> 						sizeof(sigsaved));
> 	-			set_thread_flag(TIF_RESTORE_SIGMASK);
> 			}
> 	-		ret = -ERESTARTNOHAND;
> 	+		ret = -ERESTART_XXX;
> 		} else if (sigmask)
> 			sigprocmask(SIG_SETMASK, &sigsaved, NULL);
> 
> Perhaps I missed something else, though. Not that I really think it worth
> changing, but I'll try to make a proof of concept patch on Weekend, on top
> of Roland's cleanups.
> 
> As I see it, the main disadvantage of ERESTART_ approach is that we need 2
> new ERESTART_ codes, one for ERESTARTNOHAND, another for ERESTART_RESTARTBLOCK.
> And yes, while I personally think this is "more clean", it is very subjective.

One error code more or less, that's cheap. Thread flags are a much more
limited resource.

Just my two cents,
Petr Tesarik

