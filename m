From: Robin Holt <holt@sgi.com>
Date: Thu, 20 Nov 2003 19:23:18 +0000
Subject: Re: [PATCH] - sched_clock() broken for ia64 SN platform
Message-Id: <marc-linux-ia64-106935637330507@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106928980122896@msgid-missing>
In-Reply-To: <marc-linux-ia64-106928980122896@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 20, 2003 at 10:32:29AM -0800, David Mosberger wrote:
> >>>>> On Thu, 20 Nov 2003 09:23:35 -0600, Jack Steiner <steiner@sgi.com> said:
> 
>   Jack> This is slightly off-topic, but the shared platform counter on
>   Jack> the SGI platform isnt a single counter. The counter is
>   Jack> replicated in each chipset It is synchronized thruout the
>   Jack> system so that all cpus will see the same value - ie., no
>   Jack> drift. Reading the counter does not required any off-node
>   Jack> references. There shouldnt be any scaling issues.
> 
> Ah, that's good.  Just for future reference, what's the approximate
> latency of reading this counter?

I haven't tested it recently, but it was approx 55nSec on a 900Mhz
Madison.

