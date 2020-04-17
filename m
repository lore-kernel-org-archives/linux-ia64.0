From: Matthew Wilcox <willy@infradead.org>
Date: Fri, 17 Apr 2020 11:12:33 +0000
Subject: Re: [PATCH v3 00/11] Make PageWriteback use the PageLocked optimisation
Message-Id: <20200417111233.GL5820@bombadil.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200416220130.13343-1-willy@infradead.org>
 <CAMuHMdWxhVoPCZ5+=Pf1LFpdE9vPv9GGTqTYMQP9oFz7eCxDaQ@mail.gmail.com>
In-Reply-To: <CAMuHMdWxhVoPCZ5+=Pf1LFpdE9vPv9GGTqTYMQP9oFz7eCxDaQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Linux MM <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, alpha <linux-alpha@vger.kernel.org>, linux-riscv@lists.infradead.org

On Fri, Apr 17, 2020 at 09:28:14AM +0200, Geert Uytterhoeven wrote:
> On Fri, Apr 17, 2020 at 12:01 AM Matthew Wilcox <willy@infradead.org> wrote:
> > v3:
> >  - Added implementations of clear_bit_unlock_is_negative_byte()
> >    to architectures which need it
> 
> I have two questions here?
>   1. Why not implement arch_clear_bit_unlock_is_negative_byte()
>      instead, so the kasan check in asm-generic is used everywhere?

That would be a larger change.  As I understand it (and I may misunderstand
it), I would need to rename all the clear_bit(), __clear_bit(), change_bit(),
... functions to have an 'arch_' prefix and then include instrumented-lock.h

>   2. Why not add the default implementation to
>      include/asm-generic/bitops/instrumented-lock.h, in case an arch_*()
>      variant is not provided yet?
> 
> Note that you did 1 for s390.

Well, s390 already uses instrumented-lock.h so I followed along with
what they're doing.  I don't think instrumented-lock.h is used at all on
these other architectures, but the whole bitops header files are such a
mess that I could easily have built a completely wrong mental model of
what's going on.
