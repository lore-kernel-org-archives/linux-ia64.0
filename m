From: alex_williamson@hp.com (Alex Williamson)
Date: Tue, 27 May 2003 00:44:19 +0000
Subject: Re: [Linux-ia64] i2000 won't boot for me with current 2.5.69-bk
Message-Id: <marc-linux-ia64-105590723706040@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706035@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706035@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> >>>>> "Peter" = Peter Chubb <peter@chubb.wattle.id.au> writes:
> 
> Peter> I've tracked down the problem to something in mca.c: the second
> Peter> call to get SAL error logs causes a partial reboot instead of
> Peter> returning error logs.  I instrumented bits of mca.c to see what
> Peter> was going on (hope the printk output is self-explanatory). This
> Peter> is on a uniprocessor i2000.
> 
> If I disable CONFIG_MCA the machine boots and appears to work (except
> for the ps/2 keyboard and mouse).
> 

Peter,

   See this thread:

https://lists.linuxia64.org/archives//linux-ia64/2003-March/004872.html

In short, if you're not up to at least firmware rev 117c on your i2000,
you need to upgraded.  The CPE polling between 2.4 & 2.5 should be pretty
much identical.

	Alex


