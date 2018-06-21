From: Michael Ellerman <mpe@ellerman.id.au>
Date: Thu, 21 Jun 2018 00:50:05 +0000
Subject: Re: Build regressions/improvements in v4.18-rc1
Message-Id: <87efh1vu82.fsf@concordia.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180618091729.11091-1-geert@linux-m68k.org> <CAMuHMdULmiArTvYsEqnyg5SB6PqjZnNANLAyYcqqYeYmHKJ5Dw@mail.gmail.com> <87vaafxp0k.fsf@concordia.ellerman.id.au> <CAMuHMdUfHJS-ykNr-vPPUDfGLsGr62c4R=EThw33-DFNj9ZQNg@mail.gmail.com>
In-Reply-To: <CAMuHMdUfHJS-ykNr-vPPUDfGLsGr62c4R=EThw33-DFNj9ZQNg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MIPS Mailing List <linux-mips@linux-mips.org>, linux-ia64@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

Geert Uytterhoeven <geert@linux-m68k.org> writes:
> On Tue, Jun 19, 2018 at 8:35 AM Michael Ellerman <mpe@ellerman.id.au> wrote:
>> Geert Uytterhoeven <geert@linux-m68k.org> writes:
>> > On Mon, Jun 18, 2018 at 11:18 AM Geert Uytterhoeven
>> > <geert@linux-m68k.org> wrote:
>> >> Below is the list of build error/warning regressions/improvements in
>> >> v4.18-rc1[1] compared to v4.17[2].
...
>
>> Relatedly I might move all the randconfig targets from Linus' tree into
>> a separate "linus-rand" tree, so that they don't pollute the results, as
>> I've done for linux-next.
>
> Sounds look a good thing.

OK done.

See eg:
  http://kisskb.ellerman.id.au/kisskb/head/14180/


At the moment the "head" page shows the progress/successful for that
head across all branches, so the linus-rand results get counted together
with the linus results which is a bit annoying.

I'm working on a change so that you can view a head *on a branch* so
that you only see the progress/successful for that branch. I'll try and
polish that up and get it pushed RSN.

cheers
