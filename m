From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 01 Apr 2003 20:32:23 +0000
Subject: [Linux-ia64] Re: [PATCH] sal calls w/o taking sal_lock
Message-Id: <marc-linux-ia64-105590723705379@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705378@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705378@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 01, 2003 at 12:28:26PM -0800, David Mosberger wrote:
>   Jesse> This patch adds SAL_CALL_NOLOCK so that platforms may call the SAL
>   Jesse> without taking a lock, if appropriate.  The ia64_sal_mc_rendez() has
>   Jesse> been changed to use it, since it won't return until all CPUs have been
>   Jesse> rendevoused by the SAL, if I understand correctly.  It's also used by
>   Jesse> various SN specific SAL routines that access the system controllers
>   Jesse> and might be useful to other plaforms.
> 
> http://lia64.bkbits.net:8080/to-linus-2.5/cset@1.1113?nav=index.html

Oops!  That's what I get for not checking bkbits before I post
something...  Anyway, glad it's there.

Thanks,
Jesse

