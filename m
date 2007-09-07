From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 07 Sep 2007 07:38:48 +0000
Subject: RE: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to be disabled
Message-Id: <617E1C2C70743745A92448908E030B2A025B103E@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> So far it appears to me that it will be defined for ia64 somewhere in
> asm-generic/tlb.h and in asm-ia64/tlb.h as
> platform_global_tlb_ipi_purge() something, but I'm not sure about
> that, will have to start digging.

I'm voting with David on this one ... machvec doesn't look like
the right mechanism for this (all of the non-sn2 machvecs would
potentially have to be duplicated to provide ptc.g and !ptc.g
variants ... that doesn't sound like a good plan).

-Tony
