From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 04 Dec 2003 22:06:29 +0000
Subject: Re: can't boot 2.6.0-test11
Message-Id: <marc-linux-ia64-107057735707226@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107057525104512@msgid-missing>
In-Reply-To: <marc-linux-ia64-107057525104512@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bill,

On Thu, Dec 04, 2003 at 04:56:20PM -0500, Bill Nottingham wrote:
> Trying to boot a 2.6test ia64 kernel here, I'm getting:
> 
> Loadin vmlinux...Loading Linux... 
> alloc.c(line 132):allocator: AllocatePages(2, 2, 3377699721561477, 0x40000000) failed (Not Found)
> plain_loader.c(line 291):plain_elf64: AllocatePages(3377699721561477, 0x40000000) for kernel failed
> 
> Is the kernel just horribly misbuilt somehow, or is something else
> going on?
> 
I saw your E-mail but I just did a bk pull frmo Linus's tree and I can't
even get my kernel to build using gcc-3.3.2. I get a lot of unwind related
errors:
arch/ia64/kernel/entry.S: Assembler messages:
arch/ia64/kernel/entry.S:118: Error: Operand to .fframe must be a constant
arch/ia64/kernel/entry.S:118: Error: Operand 2 of `adds' should be a 14-bit integer (-8192-8191)
arch/ia64/kernel/entry.S:118: Error:  Second operand not a valid constant
arch/ia64/kernel/entry.S:118: Error:  Second operand not a valid constant
arch/ia64/kernel/entry.S:118: Error: Second operand to .spillsp must be a constant
arch/ia64/kernel/entry.S:118: Error: Second operand to .spillsp must be a constant
arch/ia64/kernel/entry.S:118: Error: Second operand to .spillsp must be a constant


From your trace, it looks like your are trying to boot an uncompressed kernel.
What this intentional?

The AllocatePages() says you are trying to allocate 3377699721561477 4KB pages.
Clearly not something you want. Is the output of readelf -e on vmlinux decent?

-- 

-Stephane
