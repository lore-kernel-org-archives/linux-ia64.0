From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 06 May 2008 03:09:45 +0000
Subject: Re: [BUG?][2.6.25-mm1] sleeping during IRQ disabled
Message-Id: <20080506120922.AC4E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > and, I found easy reproduce way. 
> > that is
> > 
> >       % pstack $$
> > 
> > Can you reproduce it?
> 
> Oh, by the way, could it be related to Stephen Eranian's note on
> do_notify_resume_user being called too frequently? In other words, are
> you running with perfmon?

No. I don't use perfmon.


