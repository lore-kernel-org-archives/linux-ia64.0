From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 26 Jul 2004 22:36:05 +0000
Subject: Re: [BROKEN PATCH] kexec for ia64
Message-Id: <200407261536.05133.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com>
In-Reply-To: <200407261524.40804.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, July 26, 2004 3:24 pm, Jesse Barnes wrote:
>   o userspace tools need ia64 support
>   o need to deal with in-flight DMA (see FIXME in machine_kexec)

After looking at it a little more, I suppose device_shutdown() should 
theoretically deal with this.

Also, it would be nice if there were a Documentation/kexec.txt or something in 
the full patch that describes all the pieces and what the arch dependent 
functions are responsible for.  Randy, do you have anything like that written 
up somewhere that you could include in the next spin of the patch?

Thanks,
Jesse
