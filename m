From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Wed, 02 Nov 2005 22:28:00 +0000
Subject: Re: [Patch 2.6.14] Extend notify_die() hooks for IA64
Message-Id: <20051102142800.A16022@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5844.1130898771@kao2.melbourne.sgi.com>
In-Reply-To: <5844.1130898771@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 01, 2005 at 07:29:21PM -0800, Keith Owens wrote:
>    DIE_SS replaced by a generic DIE_FAULT which checks the vector number,
>    to allow interception of faults other than SS.
>    DIE_MACHINE_{HALT,RESTART} added to allow last minute close down
>    processing, especially when the halt/restart routines are called from
>    error handlers.
>    DIE_OOPS added.
>    The check for kprobe's break numbers has been moved from traps.c to
>    kprobes.c, allowing DIE_BREAK to be used for any additional break
>    numbers, i.e. it is no longer kprobes specific.

	Acked-by: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
	Good thing to move kprobes specific break numbers check from
	traps.c to kprobes.c.  Changes are fine with with me.

Thanks,
Anil S Keshavamurthy
