From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 13 Jan 2009 13:04:05 +0000
Subject: Re: [PATCH 9/9] ftrace, trivial: fix typo "resgister" ->
Message-Id: <alpine.DEB.1.10.0901130802440.31098@gandalf.stny.rr.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090113061110.856268617@goodmis.org> <20090113061148.807298761@goodmis.org> <20090113080352.GB23381@pengutronix.de>
In-Reply-To: <20090113080352.GB23381@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: =?ISO-8859-15?Q?Uwe_Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Shaohua Li <shaohua.li@intel.com>, ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Sam Ravnborg <sam@ravnborg.org>, trivial@kernel.org, Steven Rostedt <srostedt@redhat.com>


On Tue, 13 Jan 2009, Uwe Kleine-K?nig wrote:

> On Tue, Jan 13, 2009 at 01:11:19AM -0500, Steven Rostedt wrote:
> > From: Uwe Kleine-K?nig <u.kleine-koenig@pengutronix.de>
> > 
> > Signed-off-by: Uwe Kleine-K?nig <ukleinek@strlen.de>
> who ever will apply this patch, can you please take care that the '?' is
> substituted by '?' or if that is too hard, by 'oe'?

Ouch, that looks bad. I just used git am to apply it and ran it through a 
compile and boot up (never know when a comment change will break the build 
;-)

I did not look at how git checked it in.

Ingo, if you did not pull this, and since it is the last patch, I'll fix 
it in my tree.

-- Steve
