From: Khalid Aziz <khalid_aziz@hp.com>
Date: Wed, 24 Sep 2003 18:17:41 +0000
Subject: Re: [PATCH] do_gettimeofday() fails to compensate for lost ticks
Message-Id: <marc-linux-ia64-106442748200503@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442430128845@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442430128845@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> 
> >>>>> On Wed, 24 Sep 2003 11:21:19 -0600 (MDT), Khalid Aziz <khalid@fc.hp.com> said:
> 
>   Khalid> do_gettimeofday() needs to account for lost ticks before
>   Khalid> returning current time and it fails to do
>   Khalid> that. do_gettimeofday() on other architectures compensate
>   Khalid> for lost ticks correctly. Due to this bug, if you repeatedly
>   Khalid> do clock_settime() immediately followed by clock_gettime()
>   Khalid> and compare the time returned by clock_gettime() to the time
>   Khalid> set by clock_settime(), you will eventually see clock going
>   Khalid> backwards. I am attaching a test program from POSIX
>   Khalid> testsuite at the end that exposes this bug. Run this test in
>   Khalid> a continuous loop that stops when test fails.
> 
> This explanation doesn't sound right.  See the "lost" variable in
> gettimeoffset().  It's supposed to account for lost ticks.
> 
>         --david

David,

So it would seem. What would then explain clock going backwards? Here is
what I see when the test fails:

tpget37128357,995121000, tpset37128358,0

where tpget is what was returned by gettimeofday() and tpset is what was
set by settimeofday(). Clock seems to have moved back by 4.879 msec.

-- 
Khalid

==================================
Khalid Aziz                                Linux and Open Source Lab
(970)898-9214                                        Hewlett-Packard
khalid@hp.com                                       Fort Collins, CO

"The Linux kernel is subject to relentless development" 
				- Alessandro Rubini
