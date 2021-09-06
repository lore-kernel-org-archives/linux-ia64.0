From: Simon Horman <horms@verge.net.au>
Date: Mon, 06 Sep 2021 07:07:47 +0000
Subject: Re: [PATCH 2/3] ia64: Make reserve_elfcorehdr() static
Message-Id: <20210906070747.GD19281@vergenet.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1629884459.git.geert+renesas@glider.be>
 <fe236cd73b64abc4abd03dd808cb015c907f4c8c.1629884459.git.geert+renesas@glider.be>
In-Reply-To: <fe236cd73b64abc4abd03dd808cb015c907f4c8c.1629884459.git.geert+renesas@glider.be>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert+renesas@glider.be>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Jay Lan <jlan@sgi.com>, Magnus Damm <magnus.damm@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, devicetree@vger.kernel.org

On Wed, Aug 25, 2021 at 01:48:28PM +0200, Geert Uytterhoeven wrote:
> There never was a reason for reserve_elfcorehdr() to be global.
> Make the function static, and move it before its sole caller.
> 
> Fixes: cee87af2a5f75713 ("[IA64] kexec: Use EFI_LOADER_DATA for ELF core header")
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Reviewed-by: Simon Horman <horms@verge.net.au>

> ---
> This fixes a conflict triggered by
> https://lore.kernel.org/r/c7e46e50aaf87ef49bdaa61358d25b122f32b7df.1628670468.git.geert+renesas@glider.be/
> and fixed by
> https://lore.kernel.org/r/f6eabbbce0fba6da3da0264c1e1cf23c01173999.1629884393.git.geert+renesas@glider.be
>  arch/ia64/include/asm/meminit.h |  1 -
>  arch/ia64/kernel/setup.c        | 51 ++++++++++++++++-----------------
>  2 files changed, 25 insertions(+), 27 deletions(-)

...
