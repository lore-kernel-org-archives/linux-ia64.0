From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 24 Sep 2003 18:21:51 +0000
Subject: Re: [PATCH] do_gettimeofday() fails to compensate for lost ticks
Message-Id: <marc-linux-ia64-106442775500799@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442430128845@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442430128845@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 24, 2003 at 12:17:41PM -0600, Khalid Aziz wrote:
> > This explanation doesn't sound right.  See the "lost" variable in
> > gettimeoffset().  It's supposed to account for lost ticks.
> > 
> >         --david
> 
> David,
> 
> So it would seem. What would then explain clock going backwards? Here is
> what I see when the test fails:
> 
> tpget37128357,995121000, tpset37128358,0
> 
> where tpget is what was returned by gettimeofday() and tpset is what was
> set by settimeofday(). Clock seems to have moved back by 4.879 msec.

Just FYI, Martin Hicks noticed recently that 2.6 on a machine with itc
drift also has this problem.  I think John Hawkes has some ideas on how
to fix it, but I haven't had time to look at it yet.

Thanks,
Jesse
