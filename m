From: Andrew Morton <akpm@osdl.org>
Date: Thu, 12 Oct 2006 07:11:39 +0000
Subject: Re: [PATCH] IA64 export symbols empty_zero_page, ia64_ssc
Message-Id: <20061012001139.1fea6ecf.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2AA634B8@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2AA634B8@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Judith Lebzelter <judith@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 11 Oct 2006 15:52:28 -0700
"Luck, Tony" <tony.luck@intel.com> wrote:

> Judith,
> 
> +++ linux/arch/ia64/kernel/ia64_ksyms.c	2006-10-09 10:15:18.000000000 -0700
> 
> These exports are only needed for the HP simulator ... it seems
> probable that the more likely fix is change Kconfig to prevent simscsi
> from being built as a module.  I assume that any remaining SKI users
> build this into the kernel ... arch/ia64/configs/sim_defconfig sets
> CONFIG_HP_SIMSCSI=y for example.
> 

The problem is that ia64 allmodconfig now bombs out, since depmod treats
this as a hard error.

IOW, please make allmodconfig work ;)
