From: Bill Nottingham <notting@redhat.com>
Date: Thu, 04 Dec 2003 22:18:09 +0000
Subject: Re: can't boot 2.6.0-test11
Message-Id: <marc-linux-ia64-107057646606273@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107057525104512@msgid-missing>
In-Reply-To: <marc-linux-ia64-107057525104512@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian (eranian@hpl.hp.com) said: 
> On Thu, Dec 04, 2003 at 04:56:20PM -0500, Bill Nottingham wrote:
> > Trying to boot a 2.6test ia64 kernel here, I'm getting:
> > 
> > Loadin vmlinux...Loading Linux... 
> > alloc.c(line 132):allocator: AllocatePages(2, 2, 3377699721561477, 0x40000000) failed (Not Found)
> > plain_loader.c(line 291):plain_elf64: AllocatePages(3377699721561477, 0x40000000) for kernel failed
> > 
> > Is the kernel just horribly misbuilt somehow, or is something else
> > going on?
> > 
> I saw your E-mail but I just did a bk pull frmo Linus's tree and I can't
> even get my kernel to build using gcc-3.3.2. I get a lot of unwind related
> errors:

I'm using 3.2.3, not 3.3.2. Dunno if that makes a big difference.

> From your trace, it looks like your are trying to boot an uncompressed kernel.
> What this intentional?

Both uncompressed and compressed fail in the same way, I was just debugging with
uncompressed.

> The AllocatePages() says you are trying to allocate 3377699721561477 4KB pages.
> Clearly not something you want. Is the output of readelf -e on vmlinux decent?

As much as I can tell, it is. Not that that means much from me.
Jakub found the following that probably is a bug, but applying the patch
doesn't help it boot:

--- linux-2.6.0-test11/arch/ia64/kernel/vmlinux.lds.S.foo	2003-12-04 17:16:36.000000000 -0500
+++ linux-2.6.0-test11/arch/ia64/kernel/vmlinux.lds.S	2003-12-04 17:08:55.000000000 -0500
@@ -151,7 +151,7 @@
 	{ *(.con_initcall.init) }
   __con_initcall_end = .;
   __security_initcall_start = .;
-  .security_initcall.init : AT(ADDR(.security_initcall.init) - PAGE_OFFSET)
+  .security_initcall.init : AT(ADDR(.security_initcall.init) - LOAD_OFFSET)
 	{ *(.security_initcall.init) }
   __security_initcall_end = .;
   . = ALIGN(PAGE_SIZE);

Bill
