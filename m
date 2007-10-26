From: Ralf Baechle <ralf@linux-mips.org>
Date: Fri, 26 Oct 2007 12:02:13 +0000
Subject: Re: [PATCH] Remove always-true tests in irq handlers
Message-Id: <20071026120213.GA32421@linux-mips.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org> <53d6c8049d4c3999a9d33d73e385d6161b5de2b7.1193390974.git.jeff@garzik.org>
In-Reply-To: <53d6c8049d4c3999a9d33d73e385d6161b5de2b7.1193390974.git.jeff@garzik.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>
Cc: LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, netdev@vger.kernel.org

On Fri, Oct 26, 2007 at 05:40:24AM -0400, Jeff Garzik wrote:

> In these drivers, dev_id is always non-NULL.
> 
> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
> ---
>  arch/ia64/hp/sim/simeth.c                   |    5 -----
>  arch/mips/pmc-sierra/msp71xx/msp_hwbutton.c |    5 +----

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
