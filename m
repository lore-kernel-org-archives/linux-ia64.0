From: Keith Owens <kaos@sgi.com>
Date: Sat, 17 Jul 2004 23:24:54 +0000
Subject: Re: [PATCH] update sn2_defconfig to include new console
Message-Id: <4338.1090106694@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407171704.08219.jbarnes@engr.sgi.com>
In-Reply-To: <200407171704.08219.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 17 Jul 2004 17:04:08 -0400, 
Jesse Barnes <jbarnes@engr.sgi.com> wrote:
>=== arch/ia64/configs/sn2_defconfig 1.8 vs edited ==>--- 1.8/arch/ia64/configs/sn2_defconfig	2004-06-24 06:42:21 -07:00
>+++ edited/arch/ia64/configs/sn2_defconfig	2004-07-17 09:24:59 -07:00
>@@ -24,6 +24,7 @@
> # CONFIG_EMBEDDED is not set
> CONFIG_KALLSYMS=y
> CONFIG_KALLSYMS_ALL=y
>+CONFIG_KALLSYMS_EXTRA_PASS=y

CONFIG_KALLSYMS_EXTRA_PASS should not be turned on by default.  It is
only to be used when there is a bug in the kallsyms code, the extra
pass provides debugging data and lets the users continue to build while
we work out what is wrong with kallsyms.

