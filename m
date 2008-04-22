From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 22 Apr 2008 20:57:30 +0000
Subject: RE: [Patch 1/4] move XP and XPC to drivers/misc/sgi-xp -v4
Message-Id: <1FE6DD409037234FAB833C420AA843EC012AF3D7@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080422194459.GB13086@sgi.com> <20080422194656.GA14628@sgi.com>
In-Reply-To: <20080422194656.GA14628@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dean Nelson <dcn@sgi.com>
Cc: jes@sgi.com, gregkh@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

> Move XPC and XPNET from arch/ia64/sn/kernel to drivers/misc/sgi-xp.

Dean,

I applied this series on top of this morning's patch to change
the uncached allocator to support multiple page allocations.

Now I see errors in the build because xpc_partition.c doesn't
have the matching change to support the extra argument:

drivers/misc/sgi-xp/xpc_partition.c: In function `xpc_rsvd_page_init':
drivers/misc/sgi-xp/xpc_partition.c:214: error: too few arguments to function `uncached_alloc_page'
drivers/misc/sgi-xp/xpc_partition.c:233: error: too few arguments to function `uncached_free_page'

-Tony
