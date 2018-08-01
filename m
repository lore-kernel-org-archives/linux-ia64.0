From: Nick Desaulniers <ndesaulniers@google.com>
Date: Wed, 01 Aug 2018 18:21:13 +0000
Subject: Re: Getting the instruction pointer on a per arch basis
Message-Id: <CAKwvOdnAzsF_vXH4UQiQd9HwjUju_sU9R4523zxqJSphuut-7Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAKwvOdku_BOi6m2ugaef6=8+VH_+KAHH-Ch+uZZqMr8WAKARCw@mail.gmail.com>
 <CAKwvOdn1Ri2VP9hNfKwQ3WMzL278e7-3DGusZc1cwQZbk9H6nw@mail.gmail.com> <20180801074051.11fa62b3@mschwideX1>
In-Reply-To: <20180801074051.11fa62b3@mschwideX1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: schwidefsky@de.ibm.com
Cc: heiko.carstens@de.ibm.com, Yoshinori Sato <ysato@users.sourceforge.jp>, dalias@libc.org, tony.luck@intel.com, fenghua.yu@intel.com, msalter@redhat.com, jacquiot.aurelien@gmail.com, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, Pirama Arumuga Nainar <pirama@google.com>, Greg Hackmann <ghackmann@google.com>, Mark Salyzyn <salyzyn@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org, sparclinux@vger.kernel.org

On Tue, Jul 31, 2018 at 10:41 PM Martin Schwidefsky
<schwidefsky@de.ibm.com> wrote:
>
> On Tue, 31 Jul 2018 16:09:06 -0700
> Nick Desaulniers <ndesaulniers@google.com> wrote:
>
> > + More maintainers and lists for visibility
> >
> > On Tue, Jul 31, 2018 at 3:32 PM Nick Desaulniers
> > <ndesaulniers@google.com> wrote:
> > >
> > > I'm currently looking into cleaning up the code duplication between
> > > current_text_addr() and _THIS_IP_, virtually every implementation of
> > > current_text_addr() and _THIS_IP_ itself are basically:
> > >
> > > #define _THIS_IP_ ({ __label__ _l; _l: &&_l; })
> > >
> > > For a few arch's, they have inline assembly instead (for
> > > current_text_addr()).  Examples:
> > > * s390
> > > * sh
> > > * ia64
> > > * x86 (um and 32b)
> > > * c6x
> > > * sparc
> > >
> > > I have a patch that cuts down on the duplication, but I don't
> > > understand why the few arch specific implementations are necessary.  I
> > > could reduce the duplication further if it's ok to just use the
> > > statement expression.
> > >
> > > Does anyone know why this is the case?
>
> For s390 it is just that we did not know about the label trick when we
> introduced the define. The inline has an advantage though, the code
> generated with the label trick is using a LARL instruction which is
> 4 bytes, the inline assembly uses a BASR which is 2 bytes.
>
> If I use the label method in current_text_addr() the size of vmlinux
> increases by a small amount:
>
> add/remove: 33/13 grow/shrink: 101/48 up/down: 11941/-8887 (3054)

Thanks for the measurements.  Was this output produced by a utility?

> This is acceptable though, I would not mind if _THIS_IP_ and
> current_text_addr use a common definition using labels.

Thank you for this feedback Martin, I appreciate it.  Patches soon.

-- 
Thanks,
~Nick Desaulniers
