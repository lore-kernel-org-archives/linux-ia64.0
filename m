From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 22 Mar 2002 01:02:59 +0000
Subject: Re: [Linux-ia64] Trouble building cross compilers
Message-Id: <marc-linux-ia64-105590701905323@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905309@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905309@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 22, 2002 at 11:57:28AM +1100, Keith Owens wrote:
> Recent binutils complain about dangling references to discarded
> sections.  binutils is up to date, check arch.ia64/vmlinux.lds.S, it
> should have
> 
>   /* Sections to be discarded */
>   /DISCARD/ : {
>         *(.text.exit)
>         *(.data.exit)
>         *(.exitcall.exit)
>         *(.IA_64.unwind.text.exit)
>         *(.IA_64.unwind_info.text.exit)
>         }

I had just figured this out...  Downgrading to binutils-2.11 also
works.  Now to see if native builds generate the same code as cross
compiles...

Thanks,
Jesse

