From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 19 Mar 2004 01:54:44 +0000
Subject: Re: [PATCH] make level sensitive interrupt emulation default on SN2
Message-Id: <200403181754.44555.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040319014650.GA659788@sgi.com>
In-Reply-To: <20040319014650.GA659788@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Since our hw doesn't fully support level triggered interrupts, we need
this patch to force another interrupt if the line is still high after
a handler completes.  David, please apply.

Thanks,
Jesse

On Thursday 18 March 2004 5:46 pm, Jeremy Higdon wrote:
> To simulate level-triggered interrupts on SN2, we need the
> forced interrupt to be on by default.  Most PCI cards don't
> need this, but the sata_vsc driver does.



