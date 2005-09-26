From: Bob Picco <bob.picco@hp.com>
Date: Mon, 26 Sep 2005 23:40:48 +0000
Subject: Re: [PATCH 0/4] V4 ia64 SPARSEMEM
Message-Id: <20050926234048.GM16066@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050922161418.GW16066@localhost.localdomain>
In-Reply-To: <20050922161418.GW16066@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

luck wrote:	[Mon Sep 26 2005, 06:23:12PM EDT]
> On Mon, Sep 26, 2005 at 01:40:36PM -0700, Luck, Tony wrote:
> > I think it would be a good idea to bundle a set of changes to the
> > default config files along with this change
> 
> Especially as this patch breaks the build for bigsur_defconfig.
> 
> I think this is because this config is using:
> 
> 	CONFIG_DISCONTIGMEM=y
> 	# CONFIG_NUMA is not set
> 	# CONFIG_VIRTUAL_MEM_MAP is not set
> 
> but it might be more convoluted.  The failure is early, while
> building asm-offsets.s
> 
> -Tony
Okay. I obviously should have checked all default configs but didn't. Let me
look into this.  I see partially why this is happening but not the full 
picture yet.  I suspect my conditional change in nodedata.h.

bob
