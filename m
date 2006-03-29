From: Grant Grundler <iod00d@hp.com>
Date: Wed, 29 Mar 2006 20:51:06 +0000
Subject: Re: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <20060329205106.GH31225@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 29, 2006 at 11:55:13AM -0800, Chen, Kenneth W wrote:
> I also tried yesterday's snapshot 2.6.16-git17 on my tiger4, it doesn't
> boot :-(
> 
> So far we have reports on:
> 
> (1) 2.6.16.1 doesn't boot on altix
> (2) 2.6.16-git17 doesn't boot on tiger4
> (3) Jes's strange .section causing some hangs.

(4) James Bottomley couldn't boot his ZX2000 (HP ZX1 chipset) from git
yesterday either.
He had to update firmware to 2.31 version because of some changes
in 2.6.16 SAL usage exposed an older SAL bug. Alex Williamson had
dug up the details and I'm blanking on them right now.
But his zx2000 is still not able to boot.

Could be multiple, unrelated problems being reported now.

grant
