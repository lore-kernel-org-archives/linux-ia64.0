From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 26 Jan 2005 22:19:14 +0000
Subject: Re: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <200501261419.14730.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, January 26, 2005 2:13 pm, Luck, Tony wrote:
> Jesse's generic up-build patch still needs some work, right?

It just needs to be fixed in light of this patch I think.  It booted for me UP 
and SMP with both CONFIG_IA64_GENERIC and the sn2 specific config.

Jesse
