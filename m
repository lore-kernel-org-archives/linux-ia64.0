From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 20 Feb 2002 23:06:34 +0000
Subject: Re: [Linux-ia64] Bug in linker script
Message-Id: <marc-linux-ia64-105590701905156@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905140@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905140@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 20 Feb 2002 16:34:27 +0100, 
Andreas Schwab <schwab@suse.de> wrote:
>The linker script for linking vmlinux is discarding the .text.exit
>section, but not the corresponding .IA64_unwind.text.exit and
>.IA64_unwind_info.text.exit sections.  This can cause dangling relocations
>when compiling with gcc3.
>
>Andreas.
>
>--- linux/arch/ia64/vmlinux.lds.S.~1~	Tue Jul 31 19:30:09 2001
>+++ linux/arch/ia64/vmlinux.lds.S	Tue Feb 19 15:34:49 2002
>@@ -13,6 +13,8 @@
> 	*(.text.exit)
> 	*(.data.exit)
> 	*(.exitcall.exit)
>+	*(.IA_64.unwind.text.exit)
>+	*(.IA_64.unwind_info.text.exit)
> 	}
> 

One *(*.text.exit) line would be better - untested.


