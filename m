From: David Laight <David.Laight@ACULAB.COM>
Date: Wed, 19 Aug 2020 15:41:48 +0000
Subject: RE: [PATCH 00/11] Introduce kernel_clone(), kill _do_fork()
Message-Id: <df7f7e17a730405ea182ec778eec22e1@AcuMS.aculab.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200818173411.404104-1-christian.brauner@ubuntu.com>
        <20200818174447.GV17456@casper.infradead.org>
        <20200819074340.GW2674@hirez.programming.kicks-ass.net>
        <20200819084556.im5zfpm2iquzvzws@wittgenstein>
        <20200819111851.GY17456@casper.infradead.org>
        <87a6yq222c.fsf@x220.int.ebiederm.org>
        <20200819134629.mvd4nupme7q2hmtz@wittgenstein>
 <87mu2qznlv.fsf@x220.int.ebiederm.org>
In-Reply-To: <87mu2qznlv.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "'Eric W. Biederman'" <ebiederm@xmission.com>, Christian Brauner <christian.brauner@ubuntu.com>
Cc: Matthew Wilcox <willy@infradead.org>, "peterz@infradead.org" <peterz@infradead.org>, Christoph Hewllig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, Yoshinori Sato <ysato@users.sourceforge.jp>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ley Foon Tan <ley.foon.tan@intel.com>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "x86@kernel.org" <x86@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Steven Rostedt <rostedt@goodmis.org>, Stafford Horne <shorne@gmail.com>, Kars de Jong <jongk@linux-m68k.org>, Kees Cook <keescook@chromium.org>, Greentime Hu <green.hu@gmail.com>, Mauro Carvalho Chehab <mchehab+huawei@kernel.org>, Alexandre Chartre <alexandre.chartre@oracle.com>, Masami Hiramatsu <mhiramat@kernel.org>, Tom Zanussi <zanussi@kernel.org>, Xiao Yang <yangx.jy@cn.fujitsu.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "uclinux-h8-devel@lists.sourceforge.jp" <uclinux-h8-devel@lists.sourceforge.jp>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "kgdb-bugreport@lists.sourceforge.net" <kgdb-bugreport@lists.sourceforge.net>, "linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>

From: Eric W. Biederman
> Sent: 19 August 2020 16:01
...
> >> Further the design decisions of pids keeps us densly using pids.  So I
> >> expect it will be a while before we even come close to using 30 bits of
> >> pid space.
> >
> > Also because it's simply annoying to have to type really large pid
> > numbers on the shell. Yes yes, that's a very privileged
> > developer-centric complaint but it matters when you have to do a quick
> > kill -9. Chromebook users obviously won't care about how large their
> > pids are for sure.
> 
> Actually that is one of the reasons (possibly the primary reason) that
> we have chosen to keep pid numbers dense.

It also helps keep the ps output under 80 cols.

> There may be fewer users of unix shells then their used to be, and we
> may now have pidfds.  But until people stop using pids in shells it is a
> very valid reason to keep them densly packed.

ISTM that the upper limit should be increased automatically
when the number of allocated pids gets large enough that they
are likely to run out (or get reused very quickly).

Does linux have an O(1) (or do I mean o(1)) pid allocator?
Or does it have to do a linear scan to find a gap??

I made the NetBSD pid allocator/lookup use pid_array[pid & mask]
then check the high bits matched (incremented on allocate).
With a FIFO free list through the unused entries.
Fairly easy to double the size and 'unzip' when getting full.
And then allocate extra high bits to keep plenty of free
values in circulation.

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
