From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 Feb 2007 17:07:40 +0000
Subject: RE: [PATCH] [IA64] Include kexec.h in arch/ia64/kernel/process.c
Message-Id: <617E1C2C70743745A92448908E030B2A0117C67C@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20070207064935.GB726@verge.net.au>
References: <20070207064935.GB726@verge.net.au>
In-Reply-To: <20070207064935.GB726@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Horms <horms@verge.net.au>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, fastboot@lists.osdl.org
Cc: "Zou, Nanhai" <nanhai.zou@intel.com>, Khalid Aziz <khalid_aziz@hp.com>, Adrian Bunk <trivial@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <magnus.damm@gmail.com>

> kexec.h is needed by arch/ia64/kernel/process.c so for the
> declaration of kexec_disable_iosapic() which is used in machine_shutdown().

> +#include <asm/kexec.h>

I merged this into your earlier change (moving machine_shutdown() into
process.c).  Linus pulled it last night.

I also added a "#ifdef CONFIG_KEXEC" around the call to kexec_disable_iosapic()
(because I first noticed that this was undefined when building non-KEXEC kernels).
But perhaps it might have been better to #define an empty stub for this function
inside kexec.h for the #ifndef CONFIG_KEXEC case?

-Tony
