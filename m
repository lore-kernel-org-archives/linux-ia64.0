From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 26 Jan 2006 18:55:24 +0000
Subject: RE: [patch] fix ia64_hint definition for intel compiler intrinsic
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0589226D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601260424.k0Q4OXg05063@unix-os.sc.intel.com>
In-Reply-To: <200601260424.k0Q4OXg05063@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> include/asm-ia64/intel_intrin.h should just include <ia64intrin.h>.
> Why not check out my patch:
> 
> http://marc.theaimsgroup.com/?l=linux-ia64&m3475932502202&w=2

There are two patches attached to that message, the first deletes
all contents from include/asm-ia64/intel_intrin.h.  The second puts
in the #include <ia64intrin.h> together with a bunch of Linux specific
defines including:

+#define ia64_hint(x)

So I'd need Ken's patch on top of yours to make cpu_relax() actually
do something, right?

The second patch also changed some sn2 specific code and didn't get
an ack.

Overall, it would be interesting to get the ia64 kernel building and
running on icc (if only to get the benefit of different warning/error
checking in an alternate compiler).

-Tony
