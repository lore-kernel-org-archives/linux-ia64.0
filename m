From: Robin Holt <holt@sgi.com>
Date: Fri, 22 Feb 2008 06:32:20 +0000
Subject: Re: [PATCH 05/28] ia64/xen: import xen hypercall header file.
Message-Id: <20080222063220.GN11391@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12036570471664-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12036570471664-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 22, 2008 at 02:10:21PM +0900, Isaku Yamahata wrote:

I have no idea what the intent is for this patch, but I guess the end
result is merely some typedefs.  It does appear to need some cleanups

> diff --git a/include/asm-ia64/xen/interface.h b/include/asm-ia64/xen/interface.h
> new file mode 100644
> index 0000000..69418f6
> --- /dev/null
> +++ b/include/asm-ia64/xen/interface.h
...
> +#ifndef __HYPERVISOR_IF_IA64_H__
> +#define __HYPERVISOR_IF_IA64_H__

Same old comment.

> +
> +/*
> + * TODO:
> + * linux's interface header removed XEN prefix
> + * Now just work around
> + */
> +#define DEFINE_GUEST_HANDLE_STRUCT(name) \
> +	__DEFINE_XEN_GUEST_HANDLE(name, struct name)
> +#define DEFINE_GUEST_HANDLE(name)	DEFINE_XEN_GUEST_HANDLE(name)
> +#define GUEST_HANDLE(name)		XEN_GUEST_HANDLE(name)
> +
> +/* Structural guest handles introduced in 0x00030201. */
> +#if __XEN_INTERFACE_VERSION__ >= 0x00030201

Will this ever be false for the stuff in the kernel tree?  if not, we
should clean this up before committing it.

> +#define ___DEFINE_XEN_GUEST_HANDLE(name, type) \
> +    typedef struct { type *p; } __guest_handle_ ## name
> +#else
> +#define ___DEFINE_XEN_GUEST_HANDLE(name, type) \
> +    typedef type * __guest_handle_ ## name
> +#endif
> +
> +#define __DEFINE_XEN_GUEST_HANDLE(name, type) \
> +    ___DEFINE_XEN_GUEST_HANDLE(name, type)

Assuming the above cleanup is valid, why have the __ and ___ variants?

> +#define DEFINE_XEN_GUEST_HANDLE(name)   __DEFINE_XEN_GUEST_HANDLE(name, name)
> +#define XEN_GUEST_HANDLE(name)          __guest_handle_ ## name
> +#define XEN_GUEST_HANDLE_64(name)       XEN_GUEST_HANDLE(name)

By this point in the review, I am beginning to get the feeling that you
want any random group of characters that contain XEN, or GUEST to be a
valid group of characters.  I am not asking you to change anything,
merely consider whether all of the defines are really needed.  I don't
know and don't really want to know, but I do hope you take the time to
rethink the shear number of #defines that all come back to
___DEFINE_XEN_GUEST_HANDLE.

> +#define uint64_aligned_t                uint64_t
> +#define set_xen_guest_handle(hnd, val)  do { (hnd).p = val; } while (0)
> +#ifdef __XEN_TOOLS__
> +#define get_xen_guest_handle(val, hnd)  do { val = (hnd).p; } while (0)
> +#endif
> +
> +#ifndef __ASSEMBLY__
> +/* Guest handles for primitive C types. */
> +__DEFINE_XEN_GUEST_HANDLE(uchar, unsigned char);
> +__DEFINE_XEN_GUEST_HANDLE(uint,  unsigned int);
> +__DEFINE_XEN_GUEST_HANDLE(ulong, unsigned long);
> +__DEFINE_XEN_GUEST_HANDLE(u64,   unsigned long);
> +DEFINE_XEN_GUEST_HANDLE(char);
> +DEFINE_XEN_GUEST_HANDLE(int);
> +DEFINE_XEN_GUEST_HANDLE(long);
> +DEFINE_XEN_GUEST_HANDLE(void);
> +
> +typedef unsigned long xen_pfn_t;
> +DEFINE_XEN_GUEST_HANDLE(xen_pfn_t);
> +#define PRI_xen_pfn "lx"
> +#endif
> +
> +/* Arch specific VIRQs definition */
> +#define VIRQ_ITC        VIRQ_ARCH_0 /* V. Virtual itc timer */
> +#define VIRQ_MCA_CMC    VIRQ_ARCH_1 /* MCA cmc interrupt */
> +#define VIRQ_MCA_CPE    VIRQ_ARCH_2 /* MCA cpe interrupt */
> +
> +/* Maximum number of virtual CPUs in multi-processor guests. */
> +/* WARNING: before changing this, check that shared_info fits on a page */

Just asking again, but can the above be turned into either a #error,
#warn, or a BUG_ON()?

> +#define MAX_VIRT_CPUS 64
> +
> +#ifndef __ASSEMBLY__
> +
> +typedef unsigned long xen_ulong_t;
> +
> +#ifdef __XEN_TOOLS__
> +#define XEN_PAGE_SIZE XC_PAGE_SIZE
> +#else
> +#define XEN_PAGE_SIZE PAGE_SIZE
> +#endif
> +
> +#define INVALID_MFN             (~0UL)
> +
> +#define MEM_G                   (1UL << 30)
> +#define MEM_M                   (1UL << 20)
> +#define MEM_K                   (1UL << 10)
> +
> +/* Guest physical address of IO ports space.  */
> +#define IO_PORTS_PADDR          0x00000ffffc000000UL
> +#define IO_PORTS_SIZE           0x0000000004000000UL
> +
> +#define MMIO_START              (3 * MEM_G)
> +#define MMIO_SIZE               (512 * MEM_M)
> +
> +#define VGA_IO_START            0xA0000UL
> +#define VGA_IO_SIZE             0x20000
> +
> +#define LEGACY_IO_START         (MMIO_START + MMIO_SIZE)
> +#define LEGACY_IO_SIZE          (64 * MEM_M)
> +
> +#define IO_PAGE_START           (LEGACY_IO_START + LEGACY_IO_SIZE)
> +#define IO_PAGE_SIZE            XEN_PAGE_SIZE
> +
> +#define STORE_PAGE_START        (IO_PAGE_START + IO_PAGE_SIZE)
> +#define STORE_PAGE_SIZE         XEN_PAGE_SIZE
> +
> +#define BUFFER_IO_PAGE_START    (STORE_PAGE_START + STORE_PAGE_SIZE)
> +#define BUFFER_IO_PAGE_SIZE     XEN_PAGE_SIZE
> +
> +#define BUFFER_PIO_PAGE_START   (BUFFER_IO_PAGE_START + BUFFER_IO_PAGE_SIZE)
> +#define BUFFER_PIO_PAGE_SIZE    XEN_PAGE_SIZE
> +
> +#define IO_SAPIC_START          0xfec00000UL
> +#define IO_SAPIC_SIZE           0x100000
> +
> +#define PIB_START               0xfee00000UL
> +#define PIB_SIZE                0x200000
> +
> +#define GFW_START               (4 * MEM_G - 16 * MEM_M)
> +#define GFW_SIZE                (16 * MEM_M)
> +
> +/* Nvram belongs to GFW memory space  */
> +#define NVRAM_SIZE              (MEM_K * 64)
> +#define NVRAM_START             (GFW_START + 10 * MEM_M)
> +
> +#define NVRAM_VALID_SIG         0x4650494e45584948      /* "HIXENIPF" */
> +struct nvram_save_addr {
> +    unsigned long addr;
> +    unsigned long signature;
> +};
> +
> +struct pt_fpreg {
> +    union {
> +        unsigned long bits[2];
> +        long double __dummy;    /* force 16-byte alignment */
> +    } u;
> +};
> +
> +union vac {
> +    unsigned long value;
> +    struct {
> +        int a_int:1;
> +        int a_from_int_cr:1;
> +        int a_to_int_cr:1;
> +        int a_from_psr:1;
> +        int a_from_cpuid:1;
> +        int a_cover:1;
> +        int a_bsw:1;
> +        long reserved:57;
> +    };
> +};
> +typedef union vac vac_t;

I thought typedefs were frowned upon.

I only skimmed the remainder of the file.  More of the same comments you
have seen before.

> +/* xen perfmon */
> +#ifdef XEN
> +#ifndef __ASSEMBLY__
> +#ifndef _ASM_IA64_PERFMON_H
> +
> +#include <xen/list.h>   /* asm/perfmon.h requires struct list_head */
> +#include <asm/perfmon.h>

Why not just always include these two.  They should be doing their own
#ifndef's to prevent reinclusion.  If not, correct them.

Thanks,
Robin
