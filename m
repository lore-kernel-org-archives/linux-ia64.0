From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 26 Jan 2005 22:33:00 +0000
Subject: RE: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02CDCB2B@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>  Tony> Jesse's generic up-build patch still needs some work, right?
>
>Not if we change per_cpu_init() to _not_ allocate the MCA data.  I can
>cook up a patch for doing this once the above two patches show up in
>your release-2.6.11 bk tree.

Ok.  Your big fix-it patch, and Russ's addendum ar in the release tree.

-Tony
