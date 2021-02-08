From: David Sterba <dsterba@suse.cz>
Date: Mon, 08 Feb 2021 00:02:41 +0000
Subject: Re: [PATCH] ia64: Fix style guide breakage
Message-Id: <20210208000241.GN1993@twin.jikos.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210205220618.611388-1-enbyamy@gmail.com>
In-Reply-To: <20210205220618.611388-1-enbyamy@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amy Parker <enbyamy@gmail.com>
Cc: schnelle@linux.ibm.com, corbet@lwn.net, mchehab+huawei@kernel.org, tsbogend@alpha.franken.de, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Feb 05, 2021 at 02:06:18PM -0800, Amy Parker wrote:
> Some statements do not have proper spacing between their C
> keywords (commonly if and for) throughout files in the ia64 tree.
> This patch corrects this to follow the kernel code style guide.
> 
> Signed-off-by: Amy Parker <enbyamy@gmail.com>
> ---
>  arch/ia64/hp/common/sba_iommu.c  | 6 +++---
>  arch/ia64/kernel/machine_kexec.c | 2 +-
>  arch/ia64/kernel/palinfo.c       | 6 +++---

ia64 got orphaned and not maintained in 96ec72a3425d1515b6, it's just
not really worth the time to spend the time cleaning up the code base.
