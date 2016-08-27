From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 27 Aug 2016 07:29:16 +0000
Subject: Re: ia64/mm/tlb: Delete unnecessary braces
Message-Id: <a9dbe5ab-6fd5-ccc9-076e-69c4aac03801@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <201608270456.Xq7iCOiG%fengguang.wu@intel.com>
In-Reply-To: <201608270456.Xq7iCOiG%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kbuild-all@01.org, linux-ia64@vger.kernel.org, kernel-janitors@vger.kernel.org, linux-doc@vger.kernel.org
Cc: kbuild test robot <lkp@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, Julia Lawall <julia.lawall@lip6.fr>, Paolo Bonzini <pbonzini@redhat.com>

>    arch/ia64/mm/tlb.c: In function 'ia64_global_tlb_purge':
>>> arch/ia64/mm/tlb.c:247:5: warning: suggest explicit braces to avoid ambiguous 'else' [-Wparentheses]
>      if (mm != active_mm)
>         ^

Does this message from the compiler mean that there are a few
corresponding details to clarify for the Linux coding style documentation?

Regards,
Markus
