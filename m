From: Erich Focht <focht@ess.nec.de>
Date: Thu, 17 Jan 2002 18:25:08 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805872@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hmm, doesn't work, yet with 2.4.17 :-(

There must be some path where a rq->lock remains set, with some sort of
print-eip-like tool I see lockups with

load_balance  vs.   __wake_up
__wake_up     vs.   sched_tick
etc...

Tomorrow I'll try 2.5.2.

Regards,
Erich


On Wed, 16 Jan 2002, David Mosberger wrote:

> In case you're still fighting with Ingo's scheduler on 2.4.xx, you
> might want to try the attached patch.  It's a gross hack to work
> around a race condition in set_cpus_allowed().  Without this hack, the
> kernel would almost always die as soon as it tried to migrate
> ksoftirqd_CPU1 from CPU 0 to CPU 1.  With the patch, it boots up to
> the point where the serial line driver gets initialized, which is
> progress, I suppose.
> 
> The fundamental problem is that current set_cpus_allowed() lets the
> same task run on two CPUs for a brief period of time.  This violates
> scheduling assumptions made by the kernel and hence results in race
> conditions.
> 
> 	--david


