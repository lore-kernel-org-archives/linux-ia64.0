From: Kevin Buettner <kev@primenet.com>
Date: Sun, 23 Apr 2000 16:52:54 +0000
Subject: Re: [Linux-ia64] ld-linux.so
Message-Id: <marc-linux-ia64-105590678205026@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205024@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205024@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Apr 23, 11:02am, Jes Sorensen wrote:

> Laurent> In glibc/sysdeps/ia64/dl-machine.h the macro
> Laurent> TRAMPOLINE_TEMPLATE saves the input registers but not r8
> Laurent> (pointer to value returned in memory). r8 should be preserved
> Laurent> across the runtime fixup.
> 
> I know very little about the C++ ABI so this may be C++ specific.  I
> thought r8 was meant to be a return register and not an input
> register and that it's valid to clobber it in any function call,
> whether the function returns a value or void?

When the function in question returns an (non-HFA) aggregate that's
larger than 32 bytes (256 bits), r8 is an input register containing
the address of the region of memory into which to write the return
structure.  When this is the case, r8 is not an output register.  I.e,
the calling conventions do not mandate restoring the struct address.

When the aggregate happens to be an HFA, the HFA is returned in
floating point registers f8 thru f15 for HFAs of up to 8 elements.
When they're larger than 8 elements, the above convention regarding
r8 is used.


