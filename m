From: Grant Grundler <iod00d@hp.com>
Date: Tue, 27 Apr 2004 15:34:17 +0000
Subject: Re: [RFC IA64 Hotplug] [Patch 4/7] hotcpu_ia64.patch
Message-Id: <20040427153417.GB6023@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ORSMSX4041XvpFVjCRG0000016f@orsmsx404.amr.corp.intel.com>
In-Reply-To: <ORSMSX4041XvpFVjCRG0000016f@orsmsx404.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Apr 26, 2004 at 03:14:54PM -0700, David Mosberger wrote:
> Some general comments on this patch:
> 
>  - Please keep the #include list alphabetically sorted (at least in
>    the ia64-specific files).  Doing so not only makes it easier to
>    find the right include, but it also tends to expose implicit &
>    broken include-dependendencies.

related topic: this patch adds includes for both "linux/cpu.h"
and "asm/cpu.h". My understanding was one should only use
"asm/foo.h" when "linux/foo.h" is not available. Is that correct?

grant
