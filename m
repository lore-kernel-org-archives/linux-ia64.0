From: Christian Brauner <christian.brauner@ubuntu.com>
Date: Thu, 14 May 2020 07:58:08 +0000
Subject: Re: [PATCH] ia64: enable HAVE_COPY_THREAD_TLS, switch to kernel_clone_args
Message-Id: <20200514075808.krdtypxpag4tfa74@wittgenstein>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200513204848.1208864-1-christian.brauner@ubuntu.com>
 <3908561D78D1C84285E8C5FCA982C28F7F6266E0@ORSMSX115.amr.corp.intel.com>
 <79e58d9b-5a39-390c-2f0c-0d87b63442b4@physik.fu-berlin.de>
 <20200514074606.vkc35syhdep23rzh@wittgenstein>
 <6b298416-1e64-eee7-0bb4-3b1f7f67adc6@physik.fu-berlin.de>
In-Reply-To: <6b298416-1e64-eee7-0bb4-3b1f7f67adc6@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: "Luck, Tony" <tony.luck@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Qais Yousef <qais.yousef@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, May 14, 2020 at 09:53:49AM +0200, John Paul Adrian Glaubitz wrote:
> Hi Christian!
> 
> On 5/14/20 9:46 AM, Christian Brauner wrote:
> >>> My last functional ia64 machine no longer powers on. Unclear if it's just
> >>> a broken power supply or something more serious. With almost nobody
> >>> in offices/labs anymore my search for another machine is proceeding
> >>> slowly.
> >>
> >> I could test it.
> > 
> > Hey Adrian,
> > 
> > That would be excellent and much appreciated.
> > Do you think you can get it tested soon?
> 
> The kernel is currently building, you should get it by the evening (CEST).

Thank you!

> 
> The machine also serves as a Debian buildd which is why it's a bit more
> busy than other servers.

Oh? Does it also produce Debian images for ia64 similar to what is done
for sparc64?

> 
> >> As for getting a working cross-compiler for ia64 in Debian, this has
> >> been on my TODO list for a while now. Building a cross-compiler for
> >> ia64 is a bit more tricky due to it's dependency on the external
> >> libunwind.
> > 
> > I hit that roadblock as well but yeah, a cross-compiler would be
> > helpful.
> 
> It's not difficult, it's just a bit of annoying package work including
> some trial and error testing.
> 
> Once the cross-compiler is in Debian, it will be available in Ubuntu as well.

Would that based on a recent gcc? I vaguely remember a post somwhere
that gcc 10 or 11 was planning to drop support for ia64?

Thanks for your help!
Christian
