From: Paul Jackson <pj@sgi.com>
Date: Thu, 25 Aug 2005 00:57:51 +0000
Subject: Re: [PATCH 2.6.13-rc6] cpu_exclusive sched domains build fix
Message-Id: <20050824175751.3a45d031.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050824111510.11478.49764.sendpatchset@jackhammer.engr.sgi.com>
	<20050824112640.GB5197@in.ibm.com>
	<20050824044648.66f7e25a.pj@sgi.com>
	<430C617E.8080002@yahoo.com.au>
	<20050824133107.2ca733c3.pj@sgi.com>
	<430D0A95.30208@yahoo.com.au>
In-Reply-To: <430D0A95.30208@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: dino@in.ibm.com, paulus@samba.org, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, torvalds@osdl.org, mingo@elte.hu, hawkes@sgi.com

Nick wrote:
> and that it looks like what I was thinking about.

Ok - I almost have my crosstool installation healthy again.
I will actually see to it that my patch builds this time for
whatever arch's I can test on, and send this simple disabling
of sched domain mangling from cpuset-land as a real patch.

I have a couple other commitments - it will be 6 to 12 hours
before I send it in, unless someone asks for a half-baked
version sooner.

> We need to revert to a stable behaviour, however we can't risk
> major surgery to get there.

Yup.  Agreed.

Thanks for looking into this, Nick.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
