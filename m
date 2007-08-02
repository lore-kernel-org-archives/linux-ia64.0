From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 02 Aug 2007 18:09:03 +0000
Subject: Re: scripts/mod/file2alias.c cross compile problem
Message-Id: <20070802180903.GD2431@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <jewswdvqpt.fsf@sykes.suse.de> <617E1C2C70743745A92448908E030B2A02156CC1@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A02156CC1@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andreas Schwab <schwab@suse.de>, trenn@suse.de, Adrian Bunk <bunk@stusta.de>, Jan Dittmer <jdi@l4x.org>, Len Brown <lenb@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, Aug 02, 2007 at 10:40:14AM -0700, Luck, Tony wrote:
> >>>  struct acpi_device_id {
> >>>  	__u8 id[ACPI_ID_LEN];
> >>> +	__u8 dummy[FILLUP_LEN];
> >>>  	kernel_ulong_t driver_data;
> >>>  };
> >>
> >> What's so special about this structure that we get an error?
> >
> > It's special because it's a device_id structure, and those structures
> > must come out identical using either the host or the target compiler.
> 
> That didn't help me understand.  Are device_id structures visible
> in some user-level API?  If so, then I can see why they'd need to
> be the same (but then I'd be confused why this structure uses a
> "kernel_ulong_t" type).

I second this. For anything visible in userspace from
include/* we require usage of the kernel specific
__u8, __u16, __u32, __u64 typedefs but for device_id we accept
kernel_ulong_t which result in the following crap in
file2alias.c:

/* We use the ELF typedefs for kernel_ulong_t but bite the bullet and
 * use either stdint.h or inttypes.h for the rest. */
#if KERNEL_ELFCLASS = ELFCLASS32
typedef Elf32_Addr      kernel_ulong_t;
#define BITS_PER_LONG 32
#else
typedef Elf64_Addr      kernel_ulong_t;
#define BITS_PER_LONG 64
#endif

And we ought to have __u64 available.
See for example types.h from asm-i386:
#if defined(__GNUC__) && !defined(__STRICT_ANSI__)
typedef __signed__ long long __s64;
typedef unsigned long long __u64;
#endif


	Sam
