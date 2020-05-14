From: Christian Brauner <christian.brauner@ubuntu.com>
Date: Thu, 14 May 2020 07:50:01 +0000
Subject: Re: [PATCH] ia64: enable HAVE_COPY_THREAD_TLS, switch to kernel_clone_args
Message-Id: <20200514075001.c63f3isbialsacpd@wittgenstein>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200513204848.1208864-1-christian.brauner@ubuntu.com>
 <3908561D78D1C84285E8C5FCA982C28F7F6266E0@ORSMSX115.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7F6266E0@ORSMSX115.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Qais Yousef <qais.yousef@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, May 13, 2020 at 09:19:41PM +0000, Luck, Tony wrote:
> > I tried my very best to test this patch including installing Debian 3
> > and 4 to try and get my hands on a gcc version that would allow
> > cross-compiling for ia64. But no, even that wasn't possible let alone a
> > working qemu for ia64. So this is largely untested but hopefully a
> > straightforward change. If this breaks something we will hear from
> > people if they still care about new kernels on ia64 since they won't be
> > able to get any further than trying to start init. :) If this patch
> > breaks it, I'll fix it.
> 
> My last functional ia64 machine no longer powers on. Unclear if it's just
> a broken power supply or something more serious. With almost nobody
> in offices/labs anymore my search for another machine is proceeding
> slowly.

Ah. :/

> 
> Which is to say ... it won't be me noticing any breakage (at least not for
> a while).

If we can't get it tested on a machine soon, would you still be ok
proceeding with this patch?

> 
> I think Al Viro bought an ia64 on ebay a while back ... if that's still running
> perhaps he'll test?

I have to admit, that out of pure desperation I considered buying on too
on ebay. But they are still suprisingly pricy.

Christian
