From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Mon, 04 Nov 2002 15:45:49 +0000
Subject: RE: [Linux-ia64] [PATCH]ACPI fACS global lock & virtual memmap
Message-Id: <marc-linux-ia64-105590709805327@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805326@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805326@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chuck,

It looks like your mailer (my mailer?) munged the diff.  Can you
resend it as an attachment or something?

> We recently moved from 2.4.9 to 2.4.19.  We encountered 
> several problems
> when trying to boot the kernel.

[put_gate_page panic]

> The second problem encountered is a hang trying to acquire 
> the FACS global lock. 
...
> [we changed] the memory 
> constraint on the
> GLptr to a register constraint and modify the macro 
> appropriately.  This
> problem only occurs if the firmware supports the FACS global lock. The
> problem will not occur on a tiger.

With the memory constraint, the compiler passes in a register that points
to the memory location (which the compiler creates on the stack) that
contains the pointer value.  Using a register constraint "fixes" the
code that assumes that the input register contains the pointer value, not
a pointer to the value.

It does not occur on the tiger because the tiger does not support this lock?

Note that you also fixed the unlock to use release semantics instead of
acquire semantics.

> The third problem was an unsupported data reference fault 
> when executing the
> cmpxchg instruction, in the macros to acquire and release the 
> above lock.
> The global lock address passed to the macros was uncached. We 
> have moved the
> lock address into the cached memory region.  The lock is only 
> used by these
> macros so we don't belive this causes a problem unless there 
> is something
> lurking in the SAL that we are unaware of.

This is because the address was calculated based on the mapping in
region 6/"C" segment, instead of region 7/"E" segment, and cmpxchg
is only supported for "WB"/cacheable memory (region 7, not region 6).

Seems kindof a hack to OR in PAGE_OFFSET and have it "magically" change
the 0xC000... to 0xE000...  But I still don't have a better idea.

> -	acpi_gbl_common_fACS.global_lock = &(acpi_gbl_FACS->global_lock);
> +	/* Make sure it's cached identity-mapped */
> +	acpi_gbl_common_fACS.global_lock = (void
*)((ulong)&(acpi_gbl_FACS->global_lock) | PAGE_OFFSET);

Kevin

