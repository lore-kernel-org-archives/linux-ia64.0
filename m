From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 20 Feb 2006 13:24:59 +0000
Subject: Re: "BUG()" definition
Message-Id: <20060220132459.GA7712@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <43F9C027.20203@bull.net>
In-Reply-To: <43F9C027.20203@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 20, 2006 at 02:12:07PM +0100, Zoltan Menyhart wrote:
> Can someone please explain me why the generic "BUG()" definition

The "generic" case is the one we do when the architecture hasn't got
its own implementation.  For a guide to what *should* be done, you
should look at x86 instead.  There, you'll see:

        do_exit(SIGSEGV);
(see arch/i386/kernel/traps.c)

> If a task calls a kernel service, and that service detects some
> incoherency in the kernel data, then we usually call "BUG()".
> 
> Due to the actual "BUG()" definition, only the calling task gets
> killed, the system continues with the incoherent kernel data.
> 
> Maybe "die()" should call "panic()" unconditionally, instead
> of "do_exit()" ?
> 
> Thanks,
> 
> Zoltan Menyhart
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
