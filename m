From: Mark Vojkovich <mvojkovich@valinux.com>
Date: Sat, 26 Aug 2000 01:22:08 +0000
Subject: [Linux-ia64] Re: [Ia64] Netscape (32-bit) locks machine
Message-Id: <marc-linux-ia64-105590678205389@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205388@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205388@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Fri, 25 Aug 2000, Michael Madore wrote:

> It was pointed out to me that /dev/mem needs to be opened with O_SYNC, so
> that it will not be mapped write-cache.  Mapping it with write cache can
> cause lockups.  I have a patch applied in os-support/lnx_video.c that
> fixes this problem, but I still get lockups.  I was wondering if there
> are any other places in the code where this could be happening?

   /dev/mem was already being opened with O_SYNC in lnx_video.c.

 
				Mark.


