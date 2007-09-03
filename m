From: "Natalie Protasevich" <protasnb@gmail.com>
Date: Mon, 03 Sep 2007 08:06:02 +0000
Subject: Re: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to bedisabled
Message-Id: <32209efe0709030106o261aaff8g592a952bee131618@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 31 Aug 2007 09:48:07 +0800, Zou Nan hai <nanhai.zou@intel.com> wrote:
> On Fri, 2007-08-31 at 09:45, Luck, Tony wrote:
> > > Please consider the scenario when many cpus are calling
> > > ia64_global_tlb_purge at the same time without any lock.
> > > Using global variables to indicate tlb flush start and end is not safe
> > > here.
> >
> > Isn't everything protected by the
> >
> >       spin_lock(&ptcg_lock);
> >        ...
> >       spin_unlock(&ptcg_lock);
> >
> > in ia64_global_tlb_purge()?  Though the comment that this lock
> > is required for HW serialization would need to be updated to
> > note that the s/w implementation also requires this serialization.
> >
> > -Tony
>
> Ah Yes, I missed this line when reading the patch...
>
> So my comments would be
> 1. avoid declare global variables and functions in .c file.
> 2. use more precise name for global variable.to e.g
>    ia64_global_tlb_flush_start is better than flush_start.
> 3. do not use asm in .c file, use intrins instead.
>
Tony and Zou Nan hai,
Thank you very much for the review.
I am going to re-send the patch, with all the corrections except I
can't really see a good way to accommodate #1. Let me know if you have
specific suggestions on this.
Keith - I really tried to make it not to wrap, hope it will work this time.
Regards,
--Natalie
