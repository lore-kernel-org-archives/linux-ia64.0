From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 02 Nov 2004 19:36:14 +0000
Subject: Re: rename generic_defconfig to defconfig?
Message-Id: <200411021136.14824.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409221713.12673.jbarnes@engr.sgi.com>
In-Reply-To: <200409221713.12673.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, November 2, 2004 10:35 am, Luck, Tony wrote:
> >Given the above, generic_defconfig seems to be in good shape
> >to takeover as defconfig.  Tony?
>
> That sounds ok to me ... "arch/ia64/defconfig" doesn't really
> fit anyone's machine right now (does it ... speak up now if you
> are somehow depending on it).

It looks like some sort of zx1 config.

> So I assume the proposal to to update defconfig with the current
> contents of arch/ia64/configs/gen_defconfig, and then delete
> gen_defconfig?  That way defconfig is something that actually
> builds and boots on a fairly wide variety of machines.

Yep, that sounds great.

Jesse
