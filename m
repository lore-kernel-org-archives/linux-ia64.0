From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 30 Jul 2003 23:53:35 +0000
Subject: Re: [PATCH] more discontig fun
Message-Id: <marc-linux-ia64-105960923109914@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105942849830042@msgid-missing>
In-Reply-To: <marc-linux-ia64-105942849830042@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 30 Jul 2003 16:32:03 -0700, 
jbarnes@sgi.com (Jesse Barnes) wrote:
>Does this look better?  I'm sure there's more cleanup to do (and I'm not
>sure about how to do the Makefile thing for !CONFIG_DISCONTIGMEM), but
>it Works For Me (tm).
>--- a/arch/ia64/mm/Makefile	Wed Jul 30 16:30:51 2003
>+++ b/arch/ia64/mm/Makefile	Wed Jul 30 16:30:51 2003
>@@ -7,3 +7,6 @@
> obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
> obj-$(CONFIG_NUMA)	   += numa.o
> obj-$(CONFIG_DISCONTIGMEM) += discontig.o
>+ifndef CONFIG_DISCONTIGMEM
>+obj-y += contig.c
>+endif


# Include contig.c if CONFIG_DISCONTIGMEM is n or undefined
obj-$(subst $(CONFIG_DISCONTIGMEM),n,,)y += contig.c

