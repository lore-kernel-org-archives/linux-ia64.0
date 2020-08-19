From: Matthew Wilcox <willy@infradead.org>
Date: Wed, 19 Aug 2020 15:45:21 +0000
Subject: Re: [PATCH 00/11] Introduce kernel_clone(), kill _do_fork()
Message-Id: <20200819154521.GE17456@casper.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200818173411.404104-1-christian.brauner@ubuntu.com>
 <20200818174447.GV17456@casper.infradead.org>
 <20200819074340.GW2674@hirez.programming.kicks-ass.net>
 <20200819084556.im5zfpm2iquzvzws@wittgenstein>
 <20200819111851.GY17456@casper.infradead.org>
 <87a6yq222c.fsf@x220.int.ebiederm.org>
 <20200819134629.mvd4nupme7q2hmtz@wittgenstein>
 <87mu2qznlv.fsf@x220.int.ebiederm.org>
 <df7f7e17a730405ea182ec778eec22e1@AcuMS.aculab.com>
In-Reply-To: <df7f7e17a730405ea182ec778eec22e1@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@aculab.com>
Cc: "'Eric W. Biederman'" <ebiederm@xmission.com>, Christian Brauner <christian.brauner@ubuntu.com>, "peterz@infradead.org" <peterz@infradead.org>, Christoph Hewllig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, Yoshinori Sato <ysato@users.sourceforge.jp>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ley Foon Tan <ley.foon.tan@intel.com>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "x86@kernel.org" <x86@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Steven Rostedt <rostedt@goodmis.org>, Stafford Horne <shorne@gmail.com>, Kars de Jong <jongk@linux-m68k.org>, Kees Cook <keescook@chromium.org>, Greentime Hu <green.hu@gmail.com>, Mauro Carvalho Chehab <mchehab+huawei@kernel.org>, Alexandre Chartre <alexandre.chartre@oracle.com>, Masami Hiramatsu <mhiramat@kernel.org>, Tom Zanussi <zanussi@kernel.org>, Xiao Yang <yangx.jy@cn.fujitsu.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "uclinux-h8-devel@lists.sourceforge.jp" <uclinux-h8-devel@lists.sourceforge.jp>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "kgdb-bugreport@lists.sourceforge.net" <kgdb-bugreport@lists.sourceforge.net>, "linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>

On Wed, Aug 19, 2020 at 03:41:48PM +0000, David Laight wrote:
> Does linux have an O(1) (or do I mean o(1)) pid allocator?
> Or does it have to do a linear scan to find a gap??

O(log(n)).  It uses the IDR allocator, so 'n' in this case is the
number of PIDs currently allocated, and it's log_64 rather than log_2
(which makes no difference to O() but does make a bit of a difference
to performance)
