From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 09 Feb 2005 23:04:14 +0000
Subject: Re: [PATCH] CPU hotplug returns CPUs to SAL
Message-Id: <1107990255.5478.96.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <1107970828.5478.22.camel@tdi>
In-Reply-To: <1107970828.5478.22.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-02-09 at 14:38 -0800, Ashok Raj wrote:

> Could you give it a try on your systems and give an udpate.
> 
> In the meantime, i will try to incorporate the missing pieces as another update
> to this patch.

Ashok,

  I'm running it in a loop (not under load) on both a zx1 and an sx1000
based system now.  Looks good on both.  We should definitely try to be
architecturally complete on the registers that get preserved, but we
don't seem to have any obvious dependency on the missing ones.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

