From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 13 Feb 2004 07:09:11 +0000
Subject: Re: [RFC][PATCH] linux-2.6.3-rc2_ia64-cyclone_A0
Message-Id: <16428.30743.435747.878573@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1076556140.795.119.camel@cog.beaverton.ibm.com>
In-Reply-To: <1076556140.795.119.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 12 Feb 2004 18:29:35 -0800, john stultz <johnstul@us.ibm.com> said:

  John> I'm not sure I see how gettimeofday will use ITC based
  John> interpolation if the ITCdrift is off. Sure, the ITC will
  John> register a timesource, but init_cyclone_clock runs after
  John> time_init and has a negative drift value, so on the x450/x455
  John> the cyclone interpolator will be used.

  John> Am I missing something?

Yes: it's the _lightweight_ gettimeofday() handler that will get
you.  See arch/ia64/kernel/fsys.S:fsys_gettimeofday().

To date no distribution ships with light-weight syscall supported
enabled, but the support is in the current glibc, so it's only a
matter of time before this would start to bite.

	--david
