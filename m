From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Sat, 01 Nov 2003 06:39:52 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106766923419071@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> Of course, I agree with a common frame set.
> In the case of platform premising IPF, I think it is
> better to regard the Intel's Chipset as the de facto
> standard.

I think there should be an abstraction layer hiding the underlying
HW implementation. I think handling for example a memory error 
by killing the affected user application, should work on any chipset
and/or CPU architecture (if technically possible). We should not
restrict ourselves to specific platforms, I think the general trend
is that the error rate will go up because :

    - faster off-chip frequencies
	- lower supply voltages decreasing signal/noise ratio
	- higher suspectibility to cosmis rays causing SEU (Single Event Upsets)
	  due to smaller process. There are for example estimations that SEUs
	  will increase by a factor of 100 when going from a .13um process to .9um

The only alternatives to burrying a system under 50 feet of solid rock to avoid
cosmic rays and improvements in HW design (chipkill will help) is to improve
error handling and recovery.

Today we have for example the ability that an application can deal with
an unexpected event, such as a div by 0. In my eyes it would be possible
that an application also could make provisions to handle memory (or cache
errors) up to a certain extend, as long as the offending VA is known.

In other words, I would prefer the option for applications writers to 
have the option to recover within the application if is possible instead
of having the application killed (or even the OS in the current state)

Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

