From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 09 May 2003 20:44:12 +0000
Subject: Re: [Linux-ia64] [PATCH] fix timer interrupts getting lost
Message-Id: <marc-linux-ia64-105590723705711@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705596@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705596@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 23 April 2003 10:16 pm, Alex Williamson wrote:
> 
>     This patch fixes the issue of some CPUs not showing timer interrupts
> going off.  Seems during the process of sync'ing the itc, we jumped over
> the next timer value.  This patch is against 2.5.67 + ia64.  I haven't
> seen the problem on 2.4, but a quick looks seems like it's potentially
> an issue there too.  Thanks,

I applied this for 2.4 also.  Thanks!

