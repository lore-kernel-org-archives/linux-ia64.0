From: Andrew Morton <akpm@osdl.org>
Date: Thu, 12 Oct 2006 19:37:14 +0000
Subject: Re: [PATCH] IA64 export symbols empty_zero_page, ia64_ssc
Message-Id: <20061012123714.85ab4ebb.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2AA634B8@scsmsx411.amr.corp.intel.com>
	<20061012001139.1fea6ecf.akpm@osdl.org>
	<20061012175536.GA8497@intel.com>
In-Reply-To: <20061012175536.GA8497@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Judith Lebzelter <judith@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 12 Oct 2006 10:55:36 -0700
"Luck, Tony" <tony.luck@intel.com> wrote:

> On Thu, Oct 12, 2006 at 12:11:39AM -0700, Andrew Morton wrote:
> > The problem is that ia64 allmodconfig now bombs out, since depmod treats
> > this as a hard error.
> > 
> > IOW, please make allmodconfig work ;)
> 
> I tried simply swapping "tristate" for "bool":
> --- a/arch/ia64/hp/sim/Kconfig	2006-10-12 10:45:18.000000000 -0700
> +++ b/arch/ia64/hp/sim/Kconfig	2006-10-12 09:43:30.000000000 -0700
> @@ -13,7 +13,7 @@
>  	depends on HP_SIMSERIAL
>  
>  config HP_SIMSCSI
> -	tristate "Simulated SCSI disk"
> +	bool "Simulated SCSI disk"
>  	depends on SCSI
>  
>  endmenu
> 
> ... and now it fails in a new an diferent way:
> 
>   LD      .tmp_vmlinux1
> arch/ia64/hp/sim/built-in.o(.init.text+0x9d2): In function `simscsi_init':
> arch/ia64/hp/sim/simscsi.c:407: undefined reference to `scsi_host_alloc'
> arch/ia64/hp/sim/built-in.o(.init.text+0xa02):arch/ia64/hp/sim/simscsi.c:411: undefined reference to `scsi_add_host'
> arch/ia64/hp/sim/built-in.o(.init.text+0xa22):arch/ia64/hp/sim/simscsi.c:413: undefined reference to `scsi_scan_host'
> 
> presumably because we have CONFIG_HP_SIMSCSI=y but CONFIG_SCSI=m
> [Which I don't understand ... HP_SIM_SCSI "depends on SCSI", so
>  how did make allmodconfig come up with this combination?].

This happens a lot and I always forget what the fix is.

Something like

	depends on SCSI=y || (m && SCSI)

but probably not exactly that.
