From: Khalid Aziz <khalid_aziz@hp.com>
Date: Wed, 24 Sep 2003 18:31:22 +0000
Subject: Re: [PATCH] do_gettimeofday() fails to compensate for lost ticks
Message-Id: <marc-linux-ia64-106442829701638@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442430128845@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442430128845@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> Not sure off-hand and I haven't looked at the 2.4 code-base in a
> while, but aren't we double-compensating in do_settimeofday()?  There,
> we have:
> 
>                 tv->tv_usec -= gettimeoffset();
>                 tv->tv_usec -= (jiffies - wall_jiffies) * (1000000 / HZ);
> 
> Perhaps the second line just needs to go?
> 
>         --david

I bet you are right. I will try taking that line out.

--
Khalid 

==================================
Khalid Aziz                                Linux and Open Source Lab
(970)898-9214                                        Hewlett-Packard
khalid@hp.com                                       Fort Collins, CO

"The Linux kernel is subject to relentless development" 
				- Alessandro Rubini
