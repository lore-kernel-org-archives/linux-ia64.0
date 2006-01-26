From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 26 Jan 2006 19:09:58 +0000
Subject: RE: [patch] fix ia64_hint definition for intel compiler intrinsic
Message-Id: <B05667366EE6204181EABE9C1B1C0EB506C079F8@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601260424.k0Q4OXg05063@unix-os.sc.intel.com>
In-Reply-To: <200601260424.k0Q4OXg05063@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote on Thursday, January 26, 2006 10:55 AM
> There are two patches attached to that message, the first deletes
> all contents from include/asm-ia64/intel_intrin.h.  The second puts
> in the #include <ia64intrin.h> together with a bunch of Linux specific
> defines including:
> 
> +#define ia64_hint(x)
> 
> So I'd need Ken's patch on top of yours to make cpu_relax() actually
> do something, right?

I believe so.  My patch from yesterday maps kernel internal definition
of ia64_hint to icc intrinsic, which the standard intel icc header file
doesn't know anything about.  Regardless, we need that patch.

- Ken
