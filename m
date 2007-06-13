From: "Bob Picco" <bob.picco@hp.com>
Date: Wed, 13 Jun 2007 12:20:19 +0000
Subject: Re: [PATCH] ia64: Scalability improvement of gettimeofday with jitter compensation
Message-Id: <20070613122019.GI11999@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <466E0FA4.2040405@jp.fujitsu.com>
In-Reply-To: <466E0FA4.2040405@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>

Hidetoshi Seto wrote:	[Mon Jun 11 2007, 11:14:44PM EDT]
[snip]
I didn't examine your patch closely but did notice modification to the
time interpolator. I'll attempt to examine your patch with more scrutiny
in the next few days.

I will be pushing Peter Keilty's clocksource ia64 patches within the next
week or so.  At that time I'll ask for inclusion into -mm. Please see:
http://marc.info/?t7881585500001&r=1&w=2
You'll notice that the time interpolator is removed.

BTW. Peter is no longer with HP. He participated in the Employee Early
Retirement program and left May 31.

thanks,

bob
