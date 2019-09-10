From: Ingo Molnar <mingo@kernel.org>
Date: Tue, 10 Sep 2019 06:35:32 +0000
Subject: Re: [PATCH v12 11/12] open: openat2(2) syscall
Message-Id: <20190910063532.GB1579@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190904201933.10736-1-cyphar@cyphar.com>
 <20190904201933.10736-12-cyphar@cyphar.com>
 <7236f382d72130f2afbbe8940e72cc67e5c6dce0.camel@kernel.org>
 <CAHk-=whZx97Nm-gUK0ppofj2RA2LLz2vmaDUTKSSV-+yYB9q_Q@mail.gmail.com>
 <C81D6D29-F6BF-48E6-A15E-3ABCB2C992E5@amacapital.net>
 <CAHk-=whe90Ec_RRrMRLE0=bJOHNS9YmVwcytVxmrfK3oCuZF6A@mail.gmail.com>
In-Reply-To: <CAHk-=whe90Ec_RRrMRLE0=bJOHNS9YmVwcytVxmrfK3oCuZF6A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Alexei Starovoitov <ast@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, David Howells <dhowells@redhat.com>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, sparclinux@vger.kernel.org, Shuah Khan <shuah@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Tycho Andersen <tycho@tycho.ws>, Aleksa Sarai <asarai@suse.de>, Jiri Olsa <jolsa@redhat.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-mips@vger.kernel.org, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@google>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Sat, Sep 7, 2019 at 10:42 AM Andy Lutomirski <luto@amacapital.net> wrote:
> >
> > Linus, you rejected resolveat() because you wanted a *nice* API
> 
> No. I rejected resoveat() because it was a completely broken garbage
> API that couldn't do even basic stuff right (like O_CREAT).
> 
> We have a ton of flag space in the new openat2() model, we might as
> well leave the old flags alone that people are (a) used to and (b) we
> have code to support _anyway_.
> 
> Making up a new flag namespace is only going to cause us - and users -
> more work, and more confusion. For no actual advantage. It's not going
> to be "cleaner". It's just going to be worse.

I suspect there is a "add a clean new flags namespace" analogy to the 
classic "add a clean new standard" XKCD:

	https://xkcd.com/927/

Thanks,

	Ingo
