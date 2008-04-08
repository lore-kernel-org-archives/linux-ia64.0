From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 08 Apr 2008 14:53:15 +0000
Subject: Re: [PATCH 2/4] set_restore_sigmask TIF_SIGPENDING
Message-Id: <alpine.LFD.1.00.0804080748320.2886@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain> <20080329001341.7F93826FA1D@magilla.localdomain> <alpine.LFD.1.00.0803281746480.14670@woody.linux-foundation.org> <20080408113519.GA227@tv-sign.ru>
In-Reply-To: <20080408113519.GA227@tv-sign.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Nesterov <oleg@tv-sign.ru>
Cc: Roland McGrath <roland@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org



On Tue, 8 Apr 2008, Oleg Nesterov wrote:
> 
> We only need this flag as an implicit parameter to the arch dependent do_signal()
> which we can't call directly, and thus it must imply TIF_SIGPENDING, and it
> is not valid after do_signal() (should be cleared). This all looks like
> ERESTART_ magic, why should we add something else ?

I think you're right. I didn't look at the actual code-paths, but my gut 
feel says "yes, TIF_RESTORE_SIGMASK should actually have been 
-ERESTARTSIGRESTORE". That sounds like the right thing to do.

		Linus
