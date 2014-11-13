From: Thomas Gleixner <tglx@linutronix.de>
Date: Thu, 13 Nov 2014 13:51:07 +0000
Subject: Re: [PATCH 08/11] x86, mpx: [new code] decode MPX instruction to get bound violation information
Message-Id: <alpine.DEB.2.11.1411131448530.3935@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <20141112170443.B4BD0899@viggo.jf.intel.com> <20141112170509.AED2778F@viggo.jf.intel.com>
In-Reply-To: <20141112170509.AED2778F@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <dave@sr71.net>
Cc: hpa@zytor.com, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, dave.hansen@linux.intel.com

On Wed, 12 Nov 2014, Dave Hansen wrote:
> Changes from the old decoder:
>  * Use the generic decoder instead of custom functions.  Saved
>    ~70 lines of code overall.
>  * Remove insn->addr_bytes code (never used??)
>  * Make sure never to possibly overflow the regoff[] array, plus
>    check the register range correctly in 32 and 64-bit modes.
>  * Allow get_reg() to return an error and have mpx_get_addr_ref()
>    handle when it sees errors.
>  * Only call insn_get_*() near where we actually use the values
>    instead if trying to call them all at once.
>  * Handle short reads from copy_from_user() and check the actual
>    number of read bytes against what we expect from
>    insn_get_length().  If a read stops in the middle of an
>    instruction, we error out.
>  * Actually check the opcodes intead of ignoring them.
>  * Dynamically kzalloc() siginfo_t so we don't leak any stack
>    data.
>  * Detect and handle decoder failures instead of ignoring them.

Very nice work! It's easy to follow and the error handling of all
sorts is well thought out.

Thanks,

	tglx
