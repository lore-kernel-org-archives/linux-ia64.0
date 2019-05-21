From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 21 May 2019 20:23:13 +0000
Subject: Re: [PATCH 1/2] open: add close_range()
Message-Id: <CAHk-=wgtHm4t71oKbykE=awiVv2H2wCy8yH0L_FsyhHQ5OSO+Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190521150006.GJ17978@ZenIV.linux.org.uk>
 <20190521113448.20654-1-christian@brauner.io>
 <28114.1558456227@warthog.procyon.org.uk>
 <20190521164141.rbehqnghiej3gfua@brauner.io>
In-Reply-To: <20190521164141.rbehqnghiej3gfua@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christian Brauner <christian@brauner.io>
Cc: linux-ia64@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, David Howells <dhowells@redhat.com>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, sparclinux@vger.kernel.org, Shuah Khan <shuah@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Miklos Szeredi <miklos@szeredi.hu>, the arch/x86 maintainers <x86@kernel.org>, linux-mips@vger.kernel.org, linux-xtensa@linux-xtensa.org, tkjos@android.com, Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@google.com>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Al Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, "Dmitry V. Levin" <ldv@altlinux.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Florian Weimer <fweimer@redhat.com>, linux-parisc@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On Tue, May 21, 2019 at 9:41 AM Christian Brauner <christian@brauner.io> wrote:
>
> Yeah, you mentioned this before. I do like being able to specify an
> upper bound to have the ability to place fds strategically after said
> upper bound.

I suspect that's the case.

And if somebody really wants to just close everything and uses a large
upper bound, we can - if we really want to - just compare the upper
bound to the file table size, and do an optimized case for that. We do
that upper bound comparison anyway to limit the size of the walk, so
*if* it's a big deal, that case could then do the whole "shrink
fdtable" case too.

But I don't believe it's worth optimizing for unless somebody really
has a load where that is shown to be a big deal.   Just do the silly
and simple loop, and add a cond_resched() in the loop, like
close_files() does for the "we have a _lot_ of files open" case.

                   Linus
