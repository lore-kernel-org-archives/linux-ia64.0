From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 09 Apr 2008 16:14:13 +0000
Subject: Re: [PATCH 2/4] set_restore_sigmask TIF_SIGPENDING
Message-Id: <1207757653.27048.77.camel@shinybook.infradead.org>
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
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Roland McGrath <roland@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 2008-04-09 at 15:39 +0400, Oleg Nesterov wrote:
> As I see it, the main disadvantage of ERESTART_ approach is that we need 2
> new ERESTART_ codes, one for ERESTARTNOHAND, another for ERESTART_RESTARTBLOCK.
> And yes, while I personally think this is "more clean", it is very subjective.

Subjective, yeah.... personally, I don't like using ERESTART_xxx much,
because you're _not_ necessarily restarting the system call. The
separate flag for TIF_RESTORE_SIGMASK (or TLF_RESTORE_SIGMASK) seems
cleaner to me -- especially once you observe that you need new codes for
ERESTART_xxx_AND_RESTORE_SIGMASK for each ERESTART_xxx that you might
want to use in conjunction with the flags.

But I don't really care much either, if you want to change it and get
the details right.

One of the supposed advantages of TIF_RESTORE_SIGMASK in the first
place, iirc, was that it allowed us to return a result code other than
-EINTR as _well_ as restoring the signal mask. But we don't actually
make use of that possibility now anyway.

-- 
dwmw2

