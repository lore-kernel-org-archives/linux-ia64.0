From: dann frazier <dannf@hp.com>
Date: Mon, 31 May 2004 15:15:29 +0000
Subject: Re: IA64_GENERIC vs. NUMA/DISCONTIG/VIRTUAL_MEM_MAP
Message-Id: <20040531151529.GA5436@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040531044843.GA25705@dannf.org>
In-Reply-To: <20040531044843.GA25705@dannf.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, May 31, 2004 at 03:32:04PM +0100, Matthew Wilcox wrote:
> No, select forces these options on.  It's like Enhances: versus Suggests:
> (if Enhances actually worked, which it doesn't).  The reason you can't
> turn DISCONTIGMEM on with a generic kernel is because it's forced on.  I
> suspect the bug submitter was smoking something good.

I suspected that initially, but this is what confused me:
$ make oldconfig > /dev/null && grep IA64_GENERIC .config && grep CONFIG_NUMA .config
CONFIG_IA64_GENERIC=y
# CONFIG_NUMA is not set

However, I can set it by editing .config by hand, and oldconfig doesn't drop
it, so I'm good to go.

-- 
---------------------------
dann frazier
Hewlett-Packard
Linux and Open Source Lab
dannf@hp.com

