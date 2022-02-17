From: Arnd Bergmann <arnd@kernel.org>
Date: Thu, 17 Feb 2022 07:49:59 +0000
Subject: Re: [PATCH v2 00/18] clean up asm/uaccess.h, kill set_fs for good
Message-Id: <CAK8P3a3_dPbjB23QffnYMtw+5ojfwChrVC8LLMQqNctU7Nh+mQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220216131332.1489939-1-arnd@kernel.org> <00496df2-f9f2-2547-3ca3-7989e4713d6b@csgroup.eu>
In-Reply-To: <00496df2-f9f2-2547-3ca3-7989e4713d6b@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, "arnd@arndb.de" <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "dalias@libc.org" <dalias@libc.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "jcmvbkbc@gmail.com" <jcmvbkbc@gmail.com>, "guoren@kernel.org" <guoren@kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "will@kernel.org" <will@kernel.org>, "ardb@kernel.org" <ardb@kernel.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "bcain@codeaurora.org" <bcain@codeaurora.org>, "deller@gmx.de" <deller@gmx.de>, "x86@kernel.org" <x86@kernel.org>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "hca@linux.ibm.com" <hca@linux.ibm.com>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-um@lists.infradead.org" <linux-um@lists.infradead.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "green.hu@gmail.com" <green.hu@gmail.com>, "shorne@gmail.com" <shorne@gmail.com>, "monstr@monstr.eu" <monstr@monstr.eu>, "tsbogend@alpha.franken.de" <tsbogend@alpha.franken.de>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "nickhu@andestech.com" <nickhu@andestech.com>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "dinguyen@kernel.org" <dinguyen@kernel.org>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "richard@nod.at" <richard@nod.at>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "davem@davemloft.net" <davem@davemloft.net>

On Thu, Feb 17, 2022 at 8:20 AM Christophe Leroy
<christophe.leroy@csgroup.eu> wrote:
> Le 16/02/2022 à 14:13, Arnd Bergmann a écrit :
> >
> > Christoph Hellwig and a few others spent a huge effort on removing
> > set_fs() from most of the important architectures, but about half the
> > other architectures were never completed even though most of them don't
> > actually use set_fs() at all.
> >
> > I did a patch for microblaze at some point, which turned out to be fairly
> > generic, and now ported it to most other architectures, using new generic
> > implementations of access_ok() and __{get,put}_kernel_nocheck().
> >
> > Three architectures (sparc64, ia64, and sh) needed some extra work,
> > which I also completed.
> >
> > The final series contains extra cleanup changes that touch all
> > architectures. Please review and test these, so we can merge them
> > for v5.18.
>
> As a further cleanup, have you thought about making a generic version of
> clear_user() ? On almost all architectures, clear_user() does an
> access_ok() then calls __clear_user() or similar.

This already exists in include/asm-generic/uaccess.h, but that file is
currently not as easy to use as it should be. I've previously looked into
what it would take to get more architectures to use common code
in that file, but I currently have no plans to work on that.

> Maybe also the same with put_user() and get_user() ? After all it is
> just access_ok() followed by __put_user() or __get_user() ? It seems
> more tricky though, as some architectures seems to have less trivial
> stuff there.

Same here: architectures can already provide a __put_user_fn()
and __get_user_fn(), to get the generic versions of the interface,
but few architectures use that. You can actually get all the interfaces
by just providing raw_copy_from_user() and raw_copy_to_user(),
but the get_user/put_user versions you get from that are fairly
inefficient.

> I also see all architectures have a prototype for strncpy_from_user()
> and strnlen_user(). Could be a common prototype instead when we have
> GENERIC_STRNCPY_FROM_USER / GENERIC_STRNLEN_USER
>
> And we have also
> user_access_begin()/user_read_access_begin()/user_write_access_begin()
> which call access_ok() then do the real work. Could be made generic with
> call to some arch specific __user_access_begin() and friends after the
> access_ok() and eventually the might_fault().

In my opinion, the biggest win would be to move the type-agnostic part of
get_user/put_user into completely generic code, this is what architectures
get wrong the most, see patch 02/18 in this series for instance.

What I'd like to see is that architectures only provide fixed-length
versions of unsafe_get_user()/unsafe_put_user(), with the type-agnostic
versions (get_user(), __get_user(), unsafe_get_user() and their put
versions) all defined once in include/linux/uaccess.h based on those.

I tried implementing this in the past, but unfortunately the resulting
object code from my generalized implementation was worse than
what we have today, so I did not continue that work.

      Arnd
