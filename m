From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 02 May 2000 22:25:57 +0000
Subject: Re: [Linux-ia64] IP-relative calls in start.S and initfini.c
Message-Id: <marc-linux-ia64-105590678205068@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205064@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205064@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	Thanks, that seems to work. Except that the kernel that I'm running 
	(2.3.99-pre5-000424-17) doesn't seem to support the brl instruction yet.

Sorry, I forgot to mention that part.  The architecture manual requires that
the kernel emulate the brl instruction on Itaniums, which do not implement
brl in hardware.  I believe that this kernel support is still being worked
on.

So the current state is that you can link your application, but you can't
run it.  Hopefully within a few weeks you should be able to run it also.

Jim


