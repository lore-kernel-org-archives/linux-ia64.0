From: Prarit Bhargava <prarit@redhat.com>
Date: Wed, 10 Oct 2007 15:19:29 +0000
Subject: Re: "make ARCH=ia64 headers_install" generates assembly errors
Message-Id: <470CED81.3080903@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0710101035470.26393@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.64.0710101035470.26393@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



Robert P. J. Day wrote:
>   the result of running:
>
> $ make -d V=1 ARCH=ia64 headers_install
>
> Reading makefiles...
> Reading makefile `Makefile'...
> Reading makefile `/home/rpjday/k/git/scripts/Kbuild.include' (search path) (no ~ expansion)...
> Reading makefile `/home/rpjday/k/git/arch/ia64/Makefile' (search path) (no ~ expansion)...
> /home/rpjday/k/git/arch/ia64/scripts/check-segrel.S: Assembler messages:
> /home/rpjday/k/git/arch/ia64/scripts/check-segrel.S:1: Error: unknown pseudo-op: `.rodata'
> /home/rpjday/k/git/arch/ia64/scripts/check-segrel.S:2: Error: no such instruction: `data4 @segrel(start)'
> objdump: '/tmp/out26433': No such file
> /home/rpjday/k/git/arch/ia64/scripts/toolchain-flags: line 19: [: !=: unary operator expected
> /home/rpjday/k/git/arch/ia64/scripts/check-text-align.S: Assembler messages:
> /home/rpjday/k/git/arch/ia64/scripts/check-text-align.S:1: Error: unknown pseudo-op: `.proc'
> /home/rpjday/k/git/arch/ia64/scripts/check-text-align.S:2: Error: unknown pseudo-op: `.prologue'
> /home/rpjday/k/git/arch/ia64/scripts/check-text-align.S:3: Error: unknown pseudo-op: `.save'
> /home/rpjday/k/git/arch/ia64/scripts/check-text-align.S:6: Error: unknown pseudo-op: `.endp'
> readelf: Error: '/tmp/out26433': No such file
> /home/rpjday/k/git/arch/ia64/scripts/check-gas-asm.S: Assembler messages:
> /home/rpjday/k/git/arch/ia64/scripts/check-gas-asm.S:1: Error: junk at end of line, first unrecognized character is `['
> /home/rpjday/k/git/arch/ia64/scripts/check-gas-asm.S:2: Error: unknown pseudo-op: `.xdata4'
> objdump: '/tmp/out26459.o': No such file
> /home/rpjday/k/git/arch/ia64/scripts/check-gas: line 10: [: !=: unary operator expected
> Updating makefiles....
> ... etc etc ...
>
>   the issue appears to be this snippet from arch/ia64/Makefile:
>
> ...
> GAS_STATUS      = $(shell $(srctree)/arch/ia64/scripts/check-gas "$(CC)" "$(OBJDUMP)")
> CPPFLAGS += $(shell $(srctree)/arch/ia64/scripts/toolchain-flags "$(CC)" "$(OBJDUMP)" "$(READELF)")
> ...
>
>   

Are these lines even useful anymore given the current tool chain we have?

P.


>   this will obviously cause problems if you have no cross-compiler,
> which you really shouldn't need if all you're doing is installing
> headers, anyway.
>
>   the headers_install step still works, but it would be cleaner if the
> Makefile didn't try to do things like check for proper assembler when
> there's no call for it.
>
> rday
>
>   
