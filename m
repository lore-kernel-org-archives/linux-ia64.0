From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 09 Apr 2008 11:16:27 +0000
Subject: Re: [PATCH 2/4] set_restore_sigmask TIF_SIGPENDING
Message-Id: <1207739787.27048.57.camel@shinybook.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain>
	 <20080329001341.7F93826FA1D@magilla.localdomain>
	 <alpine.LFD.1.00.0803281746480.14670@woody.linux-foundation.org>
	 <20080408113519.GA227@tv-sign.ru>
In-Reply-To: <20080408113519.GA227@tv-sign.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Nesterov <oleg@tv-sign.ru>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Roland McGrath <roland@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 2008-04-08 at 15:35 +0400, Oleg Nesterov wrote:
> Why do we need any flag? It looks a bit ugly. Isn't it better to introduce
> the new magic ERESTART_XXX which means ERESTARTNOHAND + restore-sigmask ?
> 
> We only need this flag as an implicit parameter to the arch dependent do_signal()
> which we can't call directly, and thus it must imply TIF_SIGPENDING, and it
> is not valid after do_signal() (should be cleared). This all looks like
> ERESTART_ magic, why should we add something else ?
> 
> See also http://marc.info/?l=linux-kernel&m3734458516136
> 
> Of course, probably it is too late to change the implementation even if
> I am right, the question is: what I am missed?

Q: When ppoll() is interrupted by a signal, what signal mask should be
active when the signal handler is active?

I believe that the signal handler should run with the temporary sigmask
which was set by ppoll(), and the original sigmask should be restored
only when the handler completes -- and that's what we achieve with
TIF_RESTORE_SIGMASK.

So a signal which was originally enabled but is temporarily disabled by
the mask passed to ppoll() will not be able to interrupt the handler for
the signal which interrupted ppoll().

Your version will restore the original signal mask _before_ invoking the
signal handler which interrupted ppoll() -- which I believe is not the
intended semantics. And IIRC that was the whole point in implementing
ppoll() in kernel rather than trying to emulate it in userspace in the
first place.

-- 
dwmw2

