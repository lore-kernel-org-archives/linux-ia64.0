From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 19 Jun 2003 19:03:43 +0000
Subject: RE: __you_cannot_kmalloc_that_much
Message-Id: <marc-linux-ia64-105604960708951@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105604765306485@msgid-missing>
In-Reply-To: <marc-linux-ia64-105604765306485@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Tony> #define MAX_OUTPUT      (PAGE_SIZE * 16)
> 
>   Tony> ...
> 
>   up-> data = kmalloc(MAX_OUTPUT, GFP_KERNEL);
> 
>   Tony> With the default 16k page size we are trying to
>   Tony> allocate 256K of memory, which is bigger that the
>   Tony> largest size pool in include/linux/kmalloc_sizes.h
> 
> 
>   Tony> Do we need a larger pool (I don't think so) or is
>   Tony> this allocation excessive?
> 
> Clearly the latter.  If it works with 4KB page size on x86, certainly
> we don't need 4 or 8 times more space on ia64.
> 
> Can you take this up directly with the author of the offending line?

Ok, I sent an e-mail to Johannes Erdfelt (with a Cc: to the
linux-usb-users mailing list) with a patch to switch the size
to a fixed 64k.

But I'm still not out of the woods ... with this patch applied
I get a:

undefined reference to `local symbols in discarded section .exit.text'

message.  Is this related to the warning about using an old linker?

gcc: 3.2
as: GNU assembler version 2.13.90
ld: GNU ld version 2.13.90.0.2 20020802

-Tony
