From: Christopher Wedgwood <cw@sgi.com>
Date: Fri, 18 Jul 2003 02:22:24 +0000
Subject: Re: [PATCH] (2.4.21-bjorn-bk) Minimalist PAL mapping for SN2
Message-Id: <marc-linux-ia64-105849502410840@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105832171829546@msgid-missing>
In-Reply-To: <marc-linux-ia64-105832171829546@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 17, 2003 at 04:52:53PM -0600, Bjorn Helgaas wrote:

> Have you tripped over something in particular that prevents
> machvec_init() from working earlier?

I tried something similar earlier using ia64_platform_is("sn2") which
uses the ACPI data and it didn't work that early on.  Let me check
this again and also see if the machine vector approach works and
resend a patch.

> It seems a little ugly to call machvec_init() from the middle of
> efi_init(), but it looks to me like we'd have all the info we need
> at that point.

This code is only used only during boot.  Give that would prefer a
machine vector over the current suggested code though I take it?

It seems a little unnecessary and complex.  What about an explicitly
ia64_platform_is check instead?

> I'm suspecting a different problem: what happens if you try to read
> the PAL area through /dev/mem?

Checking the code it looks like and write should work.  I'm pretty
sure mmap will too but I've not checked it.  I'll probably make sure
it does work though.

That said, I'm not 100% certain that mmap semantics over the PAL
region even make sense --- for SN2 the PAL is mapped into local-node
memory and as such in theory could differ across nodes, so what
user-space sees might changes depending on what CPU you run on.

Looking at the way PAL is defined it looks like someone at Intel
allowed for the possibility of different CPUs having different PAL-code
so presumably this isn't unique to SN2.

> In 2.5, we check the EFI memmap to determine whether to use cached
> or non-cached access.

Yes, I recall this being mentioned now.  To be honest I have a really
bad case of 2.4-myopia and had to check just now though.

> For PAL, we won't find it in the memmap (because we discarded the
> whole granule), so we'll try to do uncached accesses to the PAL
> area.

Well, I'm not sure I really like the trim code (or anything else)
messing with the EFI memory map as it does --- I'd much rather see the
upper layers be smarter but that's fairly invasive changes for now.

It seems it *should* be safe to not trim PAL code and then the
efi_mem_attributes check will work correctly in 2.5.  I couldn't see
anything using the granule-sized-assumptions that would break if I did
this (in fact, I didn't trim the PAL code in an internal tree for some
time and never saw any problems on zx1, tiger or sn2 --- but I wasn't
looking hard for it).



  --cw
