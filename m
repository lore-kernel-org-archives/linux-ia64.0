From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 09 Feb 2005 19:51:20 +0000
Subject: RE: [PATCH] CPU hotplug returns CPUs to SAL
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02E2BA66@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1107970828.5478.22.camel@tdi>
In-Reply-To: <1107970828.5478.22.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   But the BSP doesn't need to save anything.  We'll always have N-1 SAL
>states saved and N-1 CPUs that can be taken offline.  As long as we
>don't hard link a state to a specific CPU, we're in good shape.  I've
>been testing on my boxes with an order that intentionally gives CPUs the
>state saved off of another CPU on OS entry.  I appear to be able to make
>the BSP return to SAL as well, but I don't think the rest of the hotplug
>code is ready for this (the other CPU doesn't seem to be getting
>scheduled).

That sounds worrying ... it assumes that the SAL thinks that
cpus are fungible, which might not be true on ccNUMA systems.

-Tony
