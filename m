From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Fri, 03 Mar 2017 14:08:37 +0000
Subject: Re: [PATCH 1/3] futex: remove duplicated code
Message-Id: <20170303140837.GF5319@osiris>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170303122712.13353-1-jslaby@suse.cz>
In-Reply-To: <20170303122712.13353-1-jslaby@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Slaby <jslaby@suse.cz>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michal Simek <monstr@monstr.eu>, Ralf Baechle <ralf@linux-mips.org>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Fri, Mar 03, 2017 at 01:27:10PM +0100, Jiri Slaby wrote:
> There is code duplicated over all architecture's headers for
> futex_atomic_op_inuser. Namely op decoding, access_ok check for uaddr,
> and comparison of the result.
> 
> Remove this duplication and leave up to the arches only the needed
> assembly which is now in arch_futex_atomic_op_inuser.
> 
> Note that s390 removed access_ok check in d12a29703 ("s390/uaccess:
> remove pointless access_ok() checks") as access_ok there returns true.
> We introduce it back to the helper for the sake of simplicity (it gets
> optimized away anyway).
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> ---
>  arch/s390/include/asm/futex.h       | 23 ++++-------------
>  include/asm-generic/futex.h         | 50 +++++++------------------------------
>  kernel/futex.c                      | 36 ++++++++++++++++++++++++++

Looks good to me and still boots on s390. Therefore for the s390 bits:
Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Thanks!

