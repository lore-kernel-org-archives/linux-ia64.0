From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 13 Jan 2005 00:36:43 +0000
Subject: Re: fixing 2.6.10 UP builds
Message-Id: <Pine.LNX.4.58.0501121633200.12977@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050106201427.GA6009@jale>
In-Reply-To: <20050106201427.GA6009@jale>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 12 Jan 2005, Jesse Barnes wrote:

> >   CC      drivers/char/mmtimer.o
> > drivers/char/mmtimer.c: In function `mmtimer_tasklet':
> > drivers/char/mmtimer.c:502: structure has no member named `write_lock'
> > make[1]: *** [drivers/char/mmtimer.o] Error 1
> > make: *** [drivers/char/mmtimer.o] Error 2
>
> Looks like we need rwlock_is_write_locked for this one.  Christoph?

Correct.


