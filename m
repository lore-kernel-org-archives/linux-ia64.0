From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 31 Jul 2008 15:29:26 +0000
Subject: Re: [PATCH 2/5] x86: Define elfcorehdr_addr in arch dependent
Message-Id: <20080731152926.GA20909@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080727234529.GM6175@verge.net.au> <20080728015117.GA12055@verge.net.au> <20080728024526.GB3334@verge.net.au> <20080728034007.GA30450@verge.net.au> <20080728211025.GA9985@redhat.com> <20080728211156.GB9985@redhat.com>
In-Reply-To: <20080728211156.GB9985@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, Andrew Morton <akpm@linux-foundation.org>, Muli Ben-Yehuda <muli@il.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Chandru <chandru@in.ibm.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, Terry Loftin <terry.loftin@hp.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Linus Torvalds <torvalds@linux-foundation.org>, Paul Mundt <lethal@linux-sh.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org


* Vivek Goyal <vgoyal@redhat.com> wrote:

> o Move elfcorehdr_addr definition in arch dependent crash dump file. This is
>   equivalent to defining elfcorehdr_addr under CONFIG_CRASH_DUMP instead of
>   CONFIG_PROC_VMCORE. This is needed by is_kdump_kernel() which can be
>   used irrespective of the fact whether CONFIG_PROC_VMCORE is enabled or
>   not.
> 
> Signed-off-by: Vivek Goyal <vgoyal@redhat.com>
> ---
> 
>  arch/x86/kernel/crash_dump_32.c |    3 +++
>  arch/x86/kernel/crash_dump_64.c |    3 +++
>  arch/x86/kernel/setup.c         |    8 +++++++-
>  3 files changed, 13 insertions(+), 1 deletion(-)

the x86 bits look fine to me.

Acked-by: Ingo Molnar <mingo@elte.hu>

	Ingo
