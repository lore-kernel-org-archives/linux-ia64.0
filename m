From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 02 Aug 2007 19:24:56 +0000
Subject: Re: scripts/mod/file2alias.c cross compile problem
Message-Id: <20070802192456.GA3509@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <jewswdvqpt.fsf@sykes.suse.de> <617E1C2C70743745A92448908E030B2A02156CC1@scsmsx411.amr.corp.intel.com> <20070802180903.GD2431@uranus.ravnborg.org> <20070802191509.GX3972@stusta.de>
In-Reply-To: <20070802191509.GX3972@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@stusta.de>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andreas Schwab <schwab@suse.de>, trenn@suse.de, Jan Dittmer <jdi@l4x.org>, Len Brown <lenb@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, rusty@rustcorp.com.au, jcm@jonmasters.org

On Thu, Aug 02, 2007 at 09:15:09PM +0200, Adrian Bunk wrote:
> On Thu, Aug 02, 2007 at 08:09:03PM +0200, Sam Ravnborg wrote:
> > 
> > I second this. For anything visible in userspace from
> > include/* we require usage of the kernel specific
> > __u8, __u16, __u32, __u64 typedefs but for device_id we accept
> > kernel_ulong_t which result in the following crap in
> > file2alias.c:
> > 
> > /* We use the ELF typedefs for kernel_ulong_t but bite the bullet and
> >  * use either stdint.h or inttypes.h for the rest. */
> > #if KERNEL_ELFCLASS = ELFCLASS32
> > typedef Elf32_Addr      kernel_ulong_t;
> > #define BITS_PER_LONG 32
> > #else
> > typedef Elf64_Addr      kernel_ulong_t;
> > #define BITS_PER_LONG 64
> > #endif
> > 
> > And we ought to have __u64 available.
> > See for example types.h from asm-i386:
> > #if defined(__GNUC__) && !defined(__STRICT_ANSI__)
> > typedef __signed__ long long __s64;
> > typedef unsigned long long __u64;
> > #endif
> 
> 
> You are talking about something different than the current problem.
> 
> The current problem is that when crosscompiling we get a different 
> _padding_ due to file2alias.c being compiled with HOSTCC.

I am well aware of that.
My point was that we are dealing with userspace - in this case depmod.
So I wondered why we had special (as in less strict) rules here.

	Sam
