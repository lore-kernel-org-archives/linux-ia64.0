From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Fri, 10 Aug 2001 15:41:26 +0000
Subject: Re: [Linux-ia64] ping(8) faster than light (do_get_fast_time) (fwd)
Message-Id: <marc-linux-ia64-105590698805055@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805052@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805052@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 10 Aug 2001, David Mosberger wrote:

> >>>>> On Fri, 10 Aug 2001 15:15:56 +0200 (CEST), Martin Wilck <Martin.Wilck@fujitsu-siemens.com> said:
>
>   Martin> The deeper reason is that on IA64, *do_get_fast_time()
>   Martin> equals do_normal_gettime(), which simply returns xtime.
>
> This distinction doesn't make sense on ia64 because there is no
> (slow) gettimeofday() to begin with.

Then, unless I'm completely mistaken, time_init() should change the
pointer do_get_fast_time to use do_gettimeofday() rather than
do_normal gettime(). Unless this is done, get_fast_time()
will simply return xtime. Or am I overlooking something?

>   Martin> 1) Is do_gettimeofday () too slow on IA64 to use it for
>   Martin> do_get_fast_time() ?
>
> I have no idea what you mean here.  On ia64 do_gettimeofday() returns
> xtime plus an itc based time offset.

Yes, but get_fast_time() doesn't (see above), and that's the function
that is called for getting timestamps for socket buffers.

Martin
-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113





