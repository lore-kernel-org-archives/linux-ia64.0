From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 20 Feb 2002 22:47:03 +0000
Subject: Re: [Linux-ia64] null pointer dereference patch
Message-Id: <marc-linux-ia64-105590701905155@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806040@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806040@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 20 Feb 2002 14:26:35 -0800, 
David Mosberger <davidm@hpl.hp.com> wrote:
>>>>>> On Wed, 20 Feb 2002 11:22:29 +1100, Keith Owens <kaos@ocs.com.au> said:
>  Keith> Some arch dependent init code relies on extable working right
>  Keith> from the start, to catch kernel operations that may or may
>  Keith> not be valid, depending on the precise hardware.  Changing
>  Keith> module_list to NULL breaks that code, the patch is correct.
>
>If you insist on the kernel module descriptor being initialized right
>from the get go, then I'd argue there should be a way for statically
>initializing this descriptor.  I really think it's a bad idea to have
>partially initialized data laying around.

The bulk of the kernel module descriptor is statically initialized,
all the common fields are filled in that way, including the extable
that init code relies on.  However archdata is a bit harder (arch
dependent initialization) and the kernel_data field cannot be
statically initialized at all.  Just have to check if those fields have
been filled in or not.  In any case it is possible (but unlikely) for a
module to be loaded that has no archdata so the field can be NULL for
modules as well.


