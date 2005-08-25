From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 25 Aug 2005 20:33:30 +0000
Subject: RE: Add PAL_VM_SUMMARY to bootloader for SKI
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F043B9B3F@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17165.3338.35854.585833@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17165.3338.35854.585833@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>+1:	cmp.eq p6,p7=PAL_MEM_ATTRIB,r28
>+(p7)	br.cond.sptk.few 1f
>+	mov	r8=0
>+	mov	r9=0x80|0x01		/* WB, NatPage */

Applied ... but why so stingy with the Attrib bits?
According to /proc/pal/cpu0/vm_info a real cpu allows
all of WB, UC, UCE, WC, NaTPage.

-Tony
