From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 26 Jan 2005 22:13:50 +0000
Subject: RE: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02CDCAEF@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>Tony, will you take the patches?  (Yes, there is still a question of
>how to cleanup/unify the MCA state allocation, but I think that's best
>done separately.)

I've been playing with the patch on a few configurations (tiger with
DIG and generic kernel still builds and boots SMP, my zx2000 is now
running UP again) and haven't seen any regressions.  So yes, I'll
apply your big patch and Russ's addendum.

Jesse's generic up-build patch still needs some work, right?

-Tony 
