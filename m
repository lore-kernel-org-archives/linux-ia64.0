From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 03 Sep 2010 21:20:03 +0000
Subject: Re: [PATCH] binfmt_misc: Fix binfmt_misc priority
Message-Id: <20100903142003.b6f02a0c.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100823141520.GB17894@alaris.suse.cz>
In-Reply-To: <20100823141520.GB17894@alaris.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Sembera <jsembera@suse.cz>
Cc: linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk, ink@jurassic.park.msu.ru, stable@kernel.org, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>


(cc stable@kernel.org and the ia64 d00ds)

On Mon, 23 Aug 2010 16:15:20 +0200
Jan Sembera <jsembera@suse.cz> wrote:

> Commit 74641f584da introduced a regression - binfmt_misc is now consulted
> after binfmt_elf, which will unfortunately break ia32el. ia32 ELF binaries
> on ia64 used to be matched using binfmt_misc and executed using wrapper. As
> 32bit binaries are now matched by binfmt_elf before bindmt_misc kicks in,
> the wrapper is ignored.
> 
> The fix increases precedence of binfmt_misc to the original state.
> 
> Signed-off-by: Jan Sembera <jsembera@suse.cz>
> ---
>  fs/binfmt_misc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/binfmt_misc.c b/fs/binfmt_misc.c
> index a7528b9..fd0cc0b 100644
> --- a/fs/binfmt_misc.c
> +++ b/fs/binfmt_misc.c
> @@ -724,7 +724,7 @@ static int __init init_misc_binfmt(void)
>  {
>  	int err = register_filesystem(&bm_fs_type);
>  	if (!err) {
> -		err = register_binfmt(&misc_format);
> +		err = insert_binfmt(&misc_format);
>  		if (err)
>  			unregister_filesystem(&bm_fs_type);
>  	}

Yikes, 74641f584da was merged in May 2009.  I wonder why this problem
wasn't noticed before now?

If we're going to change this then I guess we should change it in
2.6.36 and backport the fix as far as we can go.
