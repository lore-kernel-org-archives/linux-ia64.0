From: Andrew Morton <akpm@osdl.org>
Date: Wed, 14 Jan 2004 03:10:15 +0000
Subject: Re: [patch] efivars update for 2.6.1
Message-Id: <20040113191015.20415de3.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401131824.i0DIOMcA031105@snoqualmie.dp.intel.com>
In-Reply-To: <200401131824.i0DIOMcA031105@snoqualmie.dp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Tolentino <metolent@snoqualmie.dp.intel.com>
Cc: davidm@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, matthew.e.tolentino@intel.com

Matt Tolentino <metolent@snoqualmie.dp.intel.com> wrote:
>
> Andrew, David:
> 
> Here's a patch that has been posted here before, but not yet
> merged.

Big, isn't it?

> Essentially, it converts efivars (i.e. Matt Domsch's 
> driver that provides access to the EFI variable runtime 
> services) to export variable information and systab info via 
> sysfs.

I'd need confirmation from David M-T and if poss a quick review from Greg K-H.

From a super-quick scan:

- Someone seems to have mangled the files with an editor which doesn't
  understand hard tabs.

- This function:

	> +static void __exit
	> +efivars_exit(void)
	> +{
	> +	struct list_head *pos, *n;
	> +
	> +        spin_lock(&efivars_lock);
	> +
	> +	list_for_each_safe(pos, n, &efivar_list)
	> +		efivar_unregister(get_efivar_entry(pos));
	> +
	> +	spin_unlock(&efivars_lock);
	> +
	> +	subsystem_unregister(&vars_subsys);
	> +	firmware_unregister(&efi_subsys);
	> +}

  cannot call efivar_unregister() under spinlock - it does all sorts of
  illegal-under-spinlock things.


