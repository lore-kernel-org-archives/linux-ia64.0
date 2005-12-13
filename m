From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 13 Dec 2005 17:57:50 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <20051213175750.GA28808@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 13, 2005 at 10:42:28AM -0500, Prarit Bhargava wrote:
> Therefore the could would be something like (this is based off the existing 
> do_initcalls)
> 
> for (call = __initcall_start, platform = __platform_start;
>       call < __initcall_end; call++, platform++) {

Running two separate parallel structures seems complex.
Why not make the entries in the .initcall sections be tuples
instead of just being an array:

struct initcalls {
	initcall_t	call;
#ifdef	CONFIG_PLATFORM_SPECIFIC_INIT
	char		*platform;
#endif
};

#ifndef CONFIG_PLATFORM_SPECIFIC_INIT
#define	arch_match(str) 1
old definition of __define_initcall (modified for structure}
#else
new definition of __define_initcall initializes to "{ fn, 0 }"
plus a __define_initcall_platform() that takes the extra arg
and initializes to "{ fn, plat }"
#endif

Then the do_initcalls loop looks like this:

	struct initcalls *call;

	for (call = __initcall_start; call < __initcall_end; call++) {
		if (!arch_match(call->platform))
			continue;
		(*call->call)();


		...
	}

-Tony
