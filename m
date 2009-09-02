From: Nick Piggin <npiggin@suse.de>
Date: Wed, 02 Sep 2009 16:38:10 +0000
Subject: discontigmem vs sparsemem on ia64 platforms
Message-Id: <20090902163810.GC28052@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi guys,

I wonder why you have DISCONTIGMEM_DEFAULT selected for GENERIC, SN2, and ZX1?
You don't explicitly disable SPARSEMEM for those platforms I think, so is
there another reason than bugs for this?

My followup question... I wonder why memory hotplug is disabled for
discontigmem? It seems like there is code there to handle it (athough
I don't know the memory hotplug code well so I didn't look too closely).

Thanks,
Nick
