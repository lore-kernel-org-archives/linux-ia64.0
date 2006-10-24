From: Jack Steiner <steiner@sgi.com>
Date: Tue, 24 Oct 2006 19:47:38 +0000
Subject: Re: [patch 3/5] Dont map PAL memory if physicall calls are going to be made
Message-Id: <20061024194738.GA24381@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061023090334.467483535@tabatha.lab.ultramonkey.org>
In-Reply-To: <20061023090334.467483535@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 23, 2006 at 05:48:43PM +0900, Horms wrote:
> There seems to be no reason to map the PAL code into memory if
> physical calls are going to be made.


If you don't map PAL, I assume that all PAL calls are going to be made in
physical addressing mode. However, I don't see any code that actually forces
PAL calls to be made in physical addressing mode. Is that your intent? 
Don't you also need to save the PAL start address as a physical address.
See the call to ia64_pal_handler_init().

In addition, it looks like slave cpus still call efi_map_pal_code()
to map PAL - see start_secondary().



> 
> Signed-Off-By: Simon Horman <horms@verge.net.au>
> 
>  arch/ia64/kernel/efi.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Index: kexec-ia64-2.6/arch/ia64/kernel/efi.c
> =================================> --- kexec-ia64-2.6.orig/arch/ia64/kernel/efi.c	2006-10-05 12:51:49.000000000 +0900
> +++ kexec-ia64-2.6/arch/ia64/kernel/efi.c	2006-10-05 12:52:10.000000000 +0900
> @@ -527,7 +528,6 @@
>  	}
>  #endif
>  
> -	efi_map_pal_code();
>  	efi_enter_virtual_mode();
>  }
>  
> @@ -601,6 +601,8 @@
>  	efi.set_variable = virt_set_variable;
>  	efi.get_next_high_mono_count = virt_get_next_high_mono_count;
>  	efi.reset_system = virt_reset_system;
> +
> +	efi_map_pal_code();
>  }
>  
>  /*
> 
> --
> 
> -- 
> Horms
>   H: http://www.vergenet.net/~horms/
>   W: http://www.valinux.co.jp/en/
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


