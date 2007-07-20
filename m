From: "Bob Picco" <bob.picco@hp.com>
Date: Fri, 20 Jul 2007 10:44:59 +0000
Subject: Re: [PATCH 0/3] fix ia64 clocksource
Message-Id: <20070720104459.GF10653@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <469E2AAF.30705@jp.fujitsu.com>
In-Reply-To: <469E2AAF.30705@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Sorry for the delay in response.
Hidetoshi Seto wrote:	[Wed Jul 18 2007, 10:58:55AM EDT]
> Hi all,
> 
> This is a set of patch for ia64 clocksource to improve performance
> of fsys_gettimeofday (and also normal gettimeofday).
> 
>  [1/3] copy time structures into fsys_gtod_data
>  [2/3] separate data for jitter compensation
>  [3/3] remove cmpxchg loop in gettimeofday
> 
> Finally, the results of my test at start:
First I'd like to thank you for your work.

I recently inherited Pete's code because of his departure. We (HP) are puzzled
by the poor performance and non monotonically increasing errors. Pete's results
are in conflict with your results. Perhaps you could forward your test
program. Unfortunately I don't have a clue what Pete used for testing.

Your analysis is very thorough and quite comprehendible. I also finally
read your thread:
http://marc.info/?l=linux-ia64&m8362166319438&w=2

I need to make the cleanups Tony identified. After that how would you like to
proceed? Combining your patch 1/3 and my 1/2 seems logical.

thanks again,

bob

[snip]
