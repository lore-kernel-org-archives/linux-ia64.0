From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 13 Jan 2005 08:14:48 +0000
Subject: Re: fixing 2.6.10 UP builds
Message-Id: <20050113081448.GA18685@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050106201427.GA6009@jale>
In-Reply-To: <20050106201427.GA6009@jale>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 12, 2005 at 04:20:43PM -0800, Jesse Barnes wrote:
> >   CC      drivers/char/mmtimer.o
> > drivers/char/mmtimer.c: In function `mmtimer_tasklet':
> > drivers/char/mmtimer.c:502: structure has no member named `write_lock'
> > make[1]: *** [drivers/char/mmtimer.o] Error 1
> > make: *** [drivers/char/mmtimer.o] Error 2
> 
> Looks like we need rwlock_is_write_locked for this one.  Christoph?

Looks like the driver is doing something completely bogus which it should
stop ASAP.

