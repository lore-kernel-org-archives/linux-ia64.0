From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 04 Sep 2019 22:38:20 +0000
Subject: Re: [PATCH v12 10/12] namei: aggressively check for nd->root escape on ".." resolution
Message-Id: <CAHk-=wg7Wq1kj8kZ+SSpfU_o991woW60NWca9yBA2ccs2eNx8Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190904201933.10736-1-cyphar@cyphar.com>
 <20190904201933.10736-11-cyphar@cyphar.com>
 <CAHk-=wiod1rQMU+6Zew=cLE8uX4tUdf42bM5eKngMnNVS2My7g@mail.gmail.com>
 <20190904214856.vnvom7h5xontvngq@yavin.dot.cyphar.com>
 <CAHk-=wgcJq21Hydh7Tx5-o8empoPp7ULDBw0Am-du_Pa+fcftQ@mail.gmail.com>
 <20592.1567636276@warthog.procyon.org.uk>
In-Reply-To: <20592.1567636276@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Howells <dhowells@redhat.com>
Cc: linux-ia64@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Alexei Starovoitov <ast@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, sparclinux@vger.kernel.org, Shuah Khan <shuah@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Tycho Andersen <tycho@tycho.ws>, Aleksa Sarai <asarai@suse.de>, Jiri Olsa <jolsa@redhat.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-mips@vger.kernel.org, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@g>

On Wed, Sep 4, 2019 at 3:31 PM David Howells <dhowells@redhat.com> wrote:
>
> It ought to be reasonably easy to make them per-sb at least, I think.  We
> don't allow cross-super rename, right?

Right now the sequence count handling very much depends on it being a
global entity on the reader side, at least.

And while the rename sequence count could (and probably should) be
per-sb, the same is very much not true of the mount one.

So the rename seqcount is likely easier to fix than the mount one, but
neither of them are entirely trivial, afaik.

               Linus
