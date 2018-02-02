From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 02 Feb 2018 22:22:32 +0000
Subject: Re: [PATCH] ia64: fix ptrace(PTRACE_GETREGS) (unbreaks strace, gdb)
Message-Id: <20180202222231.23favlxecnxcencr@agluck-desk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180202221224.16597-1-slyfox@gentoo.org>
In-Reply-To: <20180202221224.16597-1-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyfox@gentoo.org>
Cc: Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Feb 02, 2018 at 10:12:24PM +0000, Sergei Trofimovich wrote:
> The strace breakage looks like that:
> ./strace: get_regs: get_regs_error: Input/output error
> 
> It happens because ia64 needs to load unwind tables
> to read certain registers. Unwind tables fail to load
> due to GCC quirk on the following code:
> 
>     extern char __end_unwind[];
>     const struct unw_table_entry *end = (struct unw_table_entry *)table_end;
>     table->end = segment_base + end[-1].end_offset;
> 
> GCC does not generate correct code for this single memory
> reference after constant propagation (see https://gcc.gnu.org/PR84184).

I'm not seeing this ... probably because I build with
a pre-historic 4.3.4 version of gcc.

Do you know which version(s) are affected? I'm not looking
for an exhaustive list, just the one on which you found this
would be good.

-Tony
