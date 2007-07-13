From: "Bob Picco" <bob.picco@hp.com>
Date: Fri, 13 Jul 2007 09:49:55 +0000
Subject: Re: [RFC][PATCH] fsys_gettimeofday leaps days if it runs with nojitter
Message-Id: <20070713094955.GF2317@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <468CA2D6.40204@jp.fujitsu.com>
In-Reply-To: <468CA2D6.40204@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Hidetoshi Seto wrote:	[Thu Jul 12 2007, 09:27:30PM EDT]
> Luck, Tony wrote:
> >>>I'm guessing here ... I haven't cross-checked with the architects.
> >>I'll be glad if we can get a comment from Intel's architects.
> >
> >I talked this through with an architect, and I'm right.  In the
> >sequence:
> >
> >	ld4.acq  rM = [rN]
> >	;;
> >	mov rP = ar.itc
> >
> >there are no dependencies, so the read of ar.itc can occur
> >"IMMEDIATELY after the load issues".
> >
> >Consuming the result of the load in between will create a
> >dependency ... so the timestamp will be taken as we want it,
> >after the load.
> >
> >So I can apply this patch (moving the "and r28 = ~1,r28").
> 
> Thank you for checking it.
> 
> >What other time patches are you still pushing?  The time
> >interpolator changes that were predicted still look like
> >they are pending somewhere (kernel/timer.c hasn't been
> >changed).
> >
> >-Tony
> 
> I don't know the current status of Bob's patches...
I was on vacation for two weeks and have spent this week catching up. I
should have Pete's patches posted by Sunday.

bob
> I hope you don't mind applying my small patches before Bob's.
> 
> Here are 2 pending patches I'm pushing :
>   - [PATCH] ia64: Scalability improvement of gettimeofday with
>             jitter compensation
>   - [PATCH] fsys_gettimeofday leaps days if it runs with nojitter
> 
> I confirmed that these 2 can be applied to 2.6.22 (with some offset).
> Let me know if you need refreshed ones.
> 
> Thanks,
> H.Seto
