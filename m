From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 02 Nov 2004 18:35:29 +0000
Subject: RE: rename generic_defconfig to defconfig?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F024B8531@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409221713.12673.jbarnes@engr.sgi.com>
In-Reply-To: <200409221713.12673.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Given the above, generic_defconfig seems to be in good shape 
>to takeover as defconfig.  Tony?

That sounds ok to me ... "arch/ia64/defconfig" doesn't really
fit anyone's machine right now (does it ... speak up now if you
are somehow depending on it).

So I assume the proposal to to update defconfig with the current
contents of arch/ia64/configs/gen_defconfig, and then delete
gen_defconfig?  That way defconfig is something that actually
builds and boots on a fairly wide variety of machines.

-Tony
