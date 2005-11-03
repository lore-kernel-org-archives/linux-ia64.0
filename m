From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 03 Nov 2005 22:33:53 +0000
Subject: RE: [PATCH] fix memory less node allocation
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04DC098C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051029212305.GA6019@localhost.localdomain>
In-Reply-To: <20051029212305.GA6019@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-	if (!ptr)
-		panic("NO memory for memory less node\n");

Why did you drop this panic?  Although your patch now
makes sure to never try to alloc from a memory less
node ... surely it is still possible (though unlikely)
that the call to __alloc_bootmem_node() might fail. A
panic here might be easier to debug than letting it run
until fill_pernode() does a memset(__va(0), 0, ...).

-Tony
