From: Christian Brauner <christian.brauner@ubuntu.com>
Date: Thu, 14 May 2020 09:57:26 +0000
Subject: Re: [PATCH] ia64: enable HAVE_COPY_THREAD_TLS, switch to kernel_clone_args
Message-Id: <20200514095726.k6k33gzldmjc6ev5@wittgenstein>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200513204848.1208864-1-christian.brauner@ubuntu.com>
 <3908561D78D1C84285E8C5FCA982C28F7F6266E0@ORSMSX115.amr.corp.intel.com>
 <79e58d9b-5a39-390c-2f0c-0d87b63442b4@physik.fu-berlin.de>
 <20200514074606.vkc35syhdep23rzh@wittgenstein>
 <20200514085801.uolf4amd3bd2aw7m@linutronix.de>
In-Reply-To: <20200514085801.uolf4amd3bd2aw7m@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Luck, Tony" <tony.luck@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Qais Yousef <qais.yousef@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, May 14, 2020 at 10:58:01AM +0200, Sebastian Andrzej Siewior wrote:
> On 2020-05-14 09:46:06 [+0200], Christian Brauner wrote:
> > > As for getting a working cross-compiler for ia64 in Debian, this has
> > > been on my TODO list for a while now. Building a cross-compiler for
> > > ia64 is a bit more tricky due to it's dependency on the external
> > > libunwind.
> > 
> > I hit that roadblock as well but yeah, a cross-compiler would be
> > helpful.
> 
> There is
>    https://mirrors.edge.kernel.org/pub/tools/crosstool/
> 
> and I used the ia64 compiler from there while compile testing patches
> for ia64.

Excellent, I've got it to compile on my system now. Let's see if it
succeeds!
Just a way to boot it afterwards would be great.

Christian
