From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 09 Apr 2008 18:40:33 +0000
Subject: Re: [PATCH 2/4] set_restore_sigmask TIF_SIGPENDING
Message-Id: <1207766433.27048.86.camel@shinybook.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain>
	 <20080329001341.7F93826FA1D@magilla.localdomain>
	 <alpine.LFD.1.00.0803281746480.14670@woody.linux-foundation.org>
	 <20080408113519.GA227@tv-sign.ru>
	 <1207739787.27048.57.camel@shinybook.infradead.org>
	 <20080409113939.GA99@tv-sign.ru>
	 <1207757653.27048.77.camel@shinybook.infradead.org>
	 <20080409162206.GA764@tv-sign.ru>
In-Reply-To: <20080409162206.GA764@tv-sign.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Nesterov <oleg@tv-sign.ru>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Roland McGrath <roland@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 2008-04-09 at 20:22 +0400, Oleg Nesterov wrote:
> On 04/09, David Woodhouse wrote:
> >
> > One of the supposed advantages of TIF_RESTORE_SIGMASK in the first
> > place, iirc, was that it allowed us to return a result code other than
> > -EINTR as _well_ as restoring the signal mask.
> 
> Agreed, good point. ERESTART_ is not that flexible.
> 
> Somehow I assumed we will never need something "special" here, this is
> not very clever.

Well, it's not clear that we _will_ need it to be so special. You could
perhaps argue that it's overengineering. It's just that at the time I
did it, I _thought_ I'd need it for ppoll().

It's only in later optimisations that I realised we only ever really
needed to use TIF_RESTORE_SIGMASK in the case where ppoll() or pselect()
was interrupted.

-- 
dwmw2

