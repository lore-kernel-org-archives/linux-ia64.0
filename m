From: Matthew Wilcox <willy@debian.org>
Date: Sat, 22 Mar 2003 13:03:57 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20 ia64_sal_mc_rendez must not lock
Message-Id: <marc-linux-ia64-105590723705291@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705290@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705290@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Mar 22, 2003 at 03:51:54PM +1100, Keith Owens wrote:
> No cpu will return from ia64_sal_mc_rendez() until all cpus have
> entered rendezvous and the monarch cpu sends the wake up ipi.  All cpus
> try to call ia64_sal_mc_rendez() but only the first one makes it, the
> others all block on the spinlock and eventually SAL hits them with an
> INIT.
> 
> Why do I get the feeling that I am the first person to really use this
> code?

Maybe this is (in part) what's causing
https://lists.linuxia64.org/archives/linux-ia64/2002-August/003876.html

Apparently the reason it hangs is that I leave my console at the default
9600 baud (you know, like a customer would ..) and when dumping state
it takes so long that the system assumes the CPU has hung.  Bag o' shite.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

