From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 08 Sep 2003 18:26:08 +0000
Subject: Re: arch/ia64/hp/common/sba_iommu.c should include version.h
Message-Id: <marc-linux-ia64-106304582419413@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106298384827966@msgid-missing>
In-Reply-To: <marc-linux-ia64-106298384827966@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

--text follows this line--
  Ian> As it uses version macros.
  Ian> This fix allows Linus bk tree to build.

I think the proper fix here is to remove the #ifdef alltogether.
Version-checks inside the main-line kernel are generally frowned upon.

Unless somebody objects, I'll make that change.

	--david

  Ian> === arch/ia64/hp/common/sba_iommu.c 1.29 vs edited ==  Ian> --- 1.29/arch/ia64/hp/common/sba_iommu.c	Mon Sep  1 09:14:08 2003
  Ian> +++ edited/arch/ia64/hp/common/sba_iommu.c	Mon Sep  8 11:02:04 2003
  Ian> @@ -33,6 +33,7 @@
  Ian> #include <linux/seq_file.h>
  Ian> #include <linux/acpi.h>
  Ian> #include <linux/efi.h>
  Ian> +#include <linux/version.h>
 
  Ian> #include <asm/delay.h>		/* ia64_get_itc() */
  Ian> #include <asm/io.h>
  Ian> --text follows this line--
