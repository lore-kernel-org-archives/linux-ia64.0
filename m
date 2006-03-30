From: Grant Grundler <iod00d@hp.com>
Date: Thu, 30 Mar 2006 22:50:47 +0000
Subject: Re: Fw: [Bugme-new] [Bug 6307] New: Bug hwclock in kernel 2.6.16
Message-Id: <20060330225047.GM4839@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060330112531.1959b11e.akpm@osdl.org>
In-Reply-To: <20060330112531.1959b11e.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 30, 2006 at 11:25:31AM -0800, Andrew Morton wrote:
> Subject: [Bugme-new] [Bug 6307] New: Bug hwclock in kernel 2.6.16
...
> Most recent kernel where this bug did not occur: Kernel 2.6.8-2-itanium-smp 
> (Defauld in Debian 3.1)

I can't reproduce this with kernel.org 2.6.15 on an HP rx2600.


> Software Environment:Debian 3.1

I'm running Debian "testing" on this box.

> Problem Description: running hwclock --hctosys or ntpdate $ip_addr_ntp_server 
> hangup the kernel.

I tried both commands and both seem to work fine.
At least they didn't hang.
I suggest looking at firmware interaction problems.

I'm upgrading system firmware so I can upgrade to 2.6.16.
(SAL needs to be updated)
If the problem is reproducable on 2.6.16, I'll post again.

hth,
grant
