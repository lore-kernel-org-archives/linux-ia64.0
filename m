From: Jason Uhlenkott <jasonuhl@sgi.com>
Date: Tue, 16 Aug 2005 20:21:42 +0000
Subject: Re: [PATCH] Make sched_clock() work in early boot
Message-Id: <20050816202142.GB753838@dragonfly.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050816195916.GA753838@dragonfly.engr.sgi.com>
In-Reply-To: <20050816195916.GA753838@dragonfly.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 16, 2005 at 01:17:33PM -0700, Luck, Tony wrote:
> >Turning on PRINTK_TIME causes us to die in early boot when sched_clock()
> >tries to access per-cpu data which isn't set up yet.
> 
> When did this break?  I tried out PRINTK_TIME when it was first added
> and it worked for me then (but since it didn't look very useful to me
> I left it off in the config files that I use ... so I haven't tried it
> since.

It's been broken for me since at least April (which was the first time
I tried it).
