From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Fri, 14 Feb 2003 06:58:53 +0000
Subject: Re: [Linux-ia64] Problem with elilo 3.3a
Message-Id: <marc-linux-ia64-105590709805848@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805846@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805846@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Charles,

On Thu, Feb 13, 2003 at 09:15:48PM -0600, Sluder, Charles wrote:
> I keep seeing hangs in the SAL that I have traced back to a corrupted EFI
> memory map. I was looking at the code for allocating the boot parameter
> block in elilo and noticed this piece of code in bootparams.c
> 
> 	/*
> 	 * Allocate memory for boot parameters.
> 	 * This CANNOT be EfiLoaderData or EfiLoaderCode as the kernel
> 	 * frees this region when initializing.
> 	 */
> 
> 	bp = (boot_params_t *)alloc(BOOT_PARAM_MEMSIZE, EfiLoaderData);
> 
> The comment seems to be at odds with the code. Is this a problem with the
> code or the comment?

The latter. The memory type is correct. In fact if you look everywhere
else in the code, you will see that we use EfiLoaderData.

You need to give some more information for us to help you here.

Note that the memory map itself IS NOT allocated inside the boot_param
structure. This structure only contains a pointer to it as well
as the size of the region. The map is dynamically allocated (in util.c).
The kernel (arch/ia64/kernel/setup.c) assumes all "valid" memory regions 
are free except for regions it knows about which are:
	- the boot param struct
	- the memory map (address in size in boot param struct)
	- initrd
	- command line string
	- kernel code and data

-- 
-Stephane

