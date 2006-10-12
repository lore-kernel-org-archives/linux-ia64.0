From: Terry Loftin <terry.loftin@hp.com>
Date: Thu, 12 Oct 2006 06:05:57 +0000
Subject: Re: [PATCH] kexec-tools: ia64: icache flush should align to 32-bytes
Message-Id: <452DDB45.2010207@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <452D72F3.50107@hp.com>
In-Reply-To: <452D72F3.50107@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



>>The destination address is aligned to 16-bytes (in kexec-elf-ia64.c), but
>>the fc.i instruction flushes a 32-byte range "associated" with that address.
>>When my command line length is 16-byte aligned but not 32-byte aligned, this
>>results in the first 16-bytes of __dummy_efi_function getting flushed (and
>>the 16 bytes prior to that), but the second half of the function (the part
>>with the br.ret) does not get flushed.  kdump then hangs in purgatory.  By
>>adding a few spaces to my command line, it becomes both 16 and 32-byte
>>aligned, and kdump works.
>>
>>
>>Thanks,
>>-T
> 
> 
> It seems I was always testing with command line more than 16 bytes length.....
> 
Maybe an example would help my explanation a bit:

A line in kexec-elf-ia64.c sets command line length
to   (strlen(command_line)+15) & ~15   thus aligning
it to 16-bytes, the needed alignment for an instruction
bundle.  (2 bundles or 32-bytes of code are copied).

The usual command line length is about 92 chars, so
command_line_len is  (92+15) & ~15 = 96   which is
both 16-byte aligned and 32-byte aligned.  This
case works fine.

But we always add " machvec=dig" to the command line to
avoid problems with the HP ioc.  Thus we have a command
line length of:  (103+15) & ~15 = 112  which is 16-byte
aligned but NOT 32-byte aligned.  In this case, our
kdump kernel always hangs in purgatory at the call to
EFI set_virtual_address_map().  This is because the
icache flush flushes on 32-byte boundaries, so only
half of the code was flushed out of the cache.  The
bit of code with the return instruction was not flushed.

By inserting 10 spaces into the command line, the new
length is  (113+15) & ~15 = 128  which is both 16 and
32-byte aligned.  In this case, kdump works fine.   This
is probably why your tests always passed (you used a
Tiger Montecito - you don't need "machvec=dig" and our
tests (on HP Montecito) always failed.

With this fix and the iosapic fix, we've completed over
200 consective kdumps without failure using our buncho test.
(Do a lot of disk and net stuff, and then panic in an
IPI handler).  So far, it looks pretty good.

-T
