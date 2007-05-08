From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 08 May 2007 20:14:26 +0000
Subject: RE: [PATCH Resend] - SN: validate smp_affinity mask on intr redirect
Message-Id: <617E1C2C70743745A92448908E030B2A01719BB8@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20070508121945.3e8d29c1.akpm@linux-foundation.org>
References: <20070508152315.26329.8428.64771@attica.americas.sgi.com>
In-Reply-To: <20070508152315.26329.8428.64771@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: John Keller <jpk@sgi.com>, linux-kernel@vger.kernel.org, steiner@sgi.com, linux-ia64@vger.kernel.org

> It had a dopey little bug:
>
> -#define is_affinity_mask_valid() 1
> +#define is_affinity_mask_valid(val) 1

That would fix warnings on non-ia64 systems (which is
a step in the right direction).  But on ia64 I have
the

#define is_affinity_mask_valid is_affinity_mask_valid

in play at that point, so I have a real function call
which doesn't have an in-scope declaration, so I get:

kernel/irq/proc.c:49: warning: implicit declaration of function `is_affinity_mask_valid'

-Tony
