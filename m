From: Jim Wilson <wilson@cygnus.com>
Date: Sat, 02 Sep 2000 03:01:21 +0000
Subject: Re: [Linux-ia64] new toolchain snapshots
Message-Id: <marc-linux-ia64-105590678205447@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205422@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205422@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	Compiling the 2.4.0-test7 code for fs/nfs/dir.c with this snapshot
	generates an unresolved reference to __multi3, for no reason that I can
	see. 

There is no reference to __multi3.  Only a declaration for it.  The .s file has
      .globl __multi3
This causes it to be put in the symbol table where nm can see it, but does
not result in any relocation for it because we aren't using it.  This should
be harmless.

	const int      slen       = strlen(".nfs") + i_inosize + countersize;
 	char           silly[slen+1];

As for how we got there, the code is using a dynamic array/variable length
array.  If the size of the array is not a constant, then we must compute its
size at runtime so we can allocate it.  The size of the array is not a
constant because of the strlen call.  We can expand this as a built-in
function, but the result isn't a constant, it is a register (that holds a
constant).  Anyways, as far as the compiler is concerned it isn't a constant.
Internally, gcc computes object sizes as both bits and bytes.  This helps with
things like bitfields and bit-strings in Pascal like languages.  Since the
maximum size of an object is 2^64 bytes, a size in bits must be computed as
a 128 bit value to avoid losing precision.  We don't support 128 values
directly, so we have to call a libgcc library routine for the multiplication.
This routine is __multi3.  After generating code, the optimizer quickly figures
out that the object size is a constant after all, and the call to __multi3
is optimized away.  However, since we thought we needed the call when first
generating code, we emitted a declaration for it, because this is the default
for ELF targets.  This is because some assemblers give an error if you use
a function or variable before declaring it.  GNU as does not have this problem,
but the Intel as does.

This problem goes away if you replace the strlen call with a 4, because then
the object size is obviously a constant, and we don't need run-time code to
compute its size in bits.

If this really needs to be fixed for some reason, then we could override the
default definition of ASM_OUTPUT_EXTERNAL_LIBCALL.  We could define it to
only emit the __multi3 declaration if ias is being used.

Jim

