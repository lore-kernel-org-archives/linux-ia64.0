From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Sun, 18 Jul 2004 19:34:04 +0000
Subject: Re: [PATCH] update sn2_defconfig to include new console
Message-Id: <200407181534.04618.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407171704.08219.jbarnes@engr.sgi.com>
In-Reply-To: <200407171704.08219.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Saturday, July 17, 2004 7:24 pm, Keith Owens wrote:
> On Sat, 17 Jul 2004 17:04:08 -0400,
>
> Jesse Barnes <jbarnes@engr.sgi.com> wrote:
> >=== arch/ia64/configs/sn2_defconfig 1.8 vs edited ==> >--- 1.8/arch/ia64/configs/sn2_defconfig	2004-06-24 06:42:21 -07:00
> >+++ edited/arch/ia64/configs/sn2_defconfig	2004-07-17 09:24:59 -07:00
> >@@ -24,6 +24,7 @@
> > # CONFIG_EMBEDDED is not set
> > CONFIG_KALLSYMS=y
> > CONFIG_KALLSYMS_ALL=y
> >+CONFIG_KALLSYMS_EXTRA_PASS=y
>
> CONFIG_KALLSYMS_EXTRA_PASS should not be turned on by default.  It is
> only to be used when there is a bug in the kallsyms code, the extra
> pass provides debugging data and lets the users continue to build while
> we work out what is wrong with kallsyms.

Oh, I see.  I thought it was a 'double check' against bad values.  I'll send 
out another update shortly that turns it off.

Thanks,
Jesse
