From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 08 Jan 2007 23:10:38 +0000
Subject: Re: + make-initkmem_list3-non-init-data-to-fix-modpost-warning.patch
Message-Id: <Pine.LNX.4.64.0701081504380.11170@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 8 Jan 2007, akpm@osdl.org wrote:

> Subject: make initkmem_list3 non init data to fix modpost warning
> From: Vivek Goyal <vgoyal@in.ibm.com>
> 
> o MODPOST generates warning for i386 if kernel is compiled with
>   CONFIG_RELOCATABLE=y
> 
> WARNING: vmlinux - Section mismatch: reference to .init.data:initkmem_list3 from .text between 'set_up_list3s' (at offset 0xc01536d9) and 's_start'
> 
> o I don't know the code well but looks like this is a bug.  initkmem_list3
>   is of type __initdata, and it is accessed by non init functions.

Well yes but the non-init function called has special behavior during 
bootstrap. initkmem_lists3 is not used after bootstrap. Everything would
be fine if we could suppress the warning.

> o Somebody who knows this code well needs to review and ack.

On a IA64 system (allows up to 1024 node nodes) this will be wasting 212 
kbyte. Some IA64 boxes only have 1 Gigabyte of memory. So we may end up
wasting 1/5th of all available memory.
