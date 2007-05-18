From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Fri, 18 May 2007 18:23:17 +0000
Subject: Re: [PATCH] get_wchan on running task sometimes MCAs the machine.
Message-Id: <ed5aea430705181123l690d293aueef65f88274f04b9@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070517111651.GA760@lnx-holt.americas.sgi.com>
In-Reply-To: <20070517111651.GA760@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hmmh, I thought we had a little helper-routine to check
memory-validity before dereferencing a pointer, but I seem to be
mixing up the (old) kernel unwinder with the one based on libunwind.
Maybe your problem will convince everybody that the libunwind-based
unwinder should be merged into mainline? ;-)  I posted the patch a
couple of months ago to the kernel list.  Probably it would need to be
freshened-up a bit.  Tony, what do you think?

  --david

On 5/17/07, Robin Holt <holt@sgi.com> wrote:
> On Thu, May 17, 2007 at 08:16:55AM -0600, David Mosberger-Tang wrote:
> > On 5/17/07, Keith Owens <kaos@sgi.com> wrote:
> >
> > >David Mosberger
> > >reckons that unwind should never cause an error, maybe we should be
> > >looking at adding more checks to the unwind code to cope with spurious
> > >addresses?
> >
> > That's correct.  If the unwinder causes MCAs, it's broken.  Robin, can
> > you look into why the memory-access safety-checks in the unwinder
> > aren't sufficient to avoid the MCAs you're seeing?
>
> I don't think it got very far at all.
>
> The task in question is calling get_wchan on itself.  It is at
> >> px *(task_struct *)0xe003819a00000000 | grep ksp
>                 ksp = 0xe003819a00007900
> >> px 0xe003819a00007900 + 16
> 0xe003819a00007910
> >> px *(switch_stack *)0xe003819a00007910 | grep bsp
>         ar_bspstore = 0xe003819a00000000
>
>
> Here we start to run into difficulties.  ar_bspstore is the same address
> as our task_struct.  info->regstk.top = 0xe003819a00000000 which leads
> to unw_init_frame_info calculating info->bsp = 0xe0038199ffffff30
> which is near the addresses causing problems (0xe0038199ffffff80 and
> 0xe0038199ffffffe0).  Notice it is in the page before our task_struct.
>
> Well, time for bed.
>
> Thanks,
> Robin
>


-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
