From: Song Liu <song@kernel.org>
Date: Sun, 28 May 2023 05:24:24 +0000
Subject: Re: Boot regression in Linux v6.4-rc3
Message-Id: <CAPhsuW7Gcd7hkrD6RtBdJDMdVnaN8Bv_kVNdpyccUiuD-TqYDw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
In-Reply-To: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

On Sat, May 27, 2023 at 12:34 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Sat, May 27, 2023 at 11:41 AM Frank Scheiner <frank.scheiner@web.de> wrote:
> >
> > Ok, I put the decoded console messages on [2].
> >
> > [2]: https://pastebin.com/dLYMijfS
>
> Ugh. Apparently ia64 decoding isn't great. But at least it gives
> multiple line numbers:
>
>    load_module (kernel/module/main.c:2291 kernel/module/main.c:2412
> kernel/module/main.c:2868)
>
> except your kernel obviously has those test-patches, so I still don't
> know exactly where they are.
>
> But it looks like it is in move_module(). Strange. I don't know how it
> gets to "__copy_user" from there...
>
> [ Looks at the ia64 code ]
>
> Oh.
>
> It turns out that it *says* __copy_user(), but the code is actually
> shared with the regular memcpy() function, which does
>
>   GLOBAL_ENTRY(memcpy)
>         and     r28=0x7,in0
>         and     r29=0x7,in1
>         mov     f6=f0
>         mov     retval=in0
>         br.cond.sptk .common_code
>         ;;
>
> where that ".common_code" label is - surprise surprise - the common
> copy code, and so when the oops reports that the problem happened in
> __copy_user(), it actually is in this case just a normal memcpy.
>
> Ok, so it's probably the
>
>         memcpy(dest, (void *)shdr->sh_addr, shdr->sh_size);
>
> in move_module() that takes a fault.  And looking at the registers,
> the destination is in r17/r18, and your dump has
>
>     unable to handle kernel paging request at virtual address 1000000000000000
>     ...
>     r17 : 0fffffffffffffff r18 : 1000000000000000
>
> so it's almost certainly that 'dest' that is bad.

Yeah, it appears we are writing to mod_mem[MOD_INVALID].

From the log, the following sections are assigned to MOD_INVALID:

[ 4.009109] __layout_sections: section .got (sh_flags 10000002)
matched to MOD_INVALID
[ 4.009109] __layout_sections: section .sdata (sh_flags 10000003)
matched to MOD_INVALID
[ 4.009109] __layout_sections: section .sbss (sh_flags 10000003)
matched to MOD_INVALID

AFAICT,  .got should go to rodata, while .sdata and .sbss should go
to (rw)data. However, reading the code before the module_memory
change, I think they were all copied to (rw)data, which is not ideal but
most likely OK.

To match the behavior before the module_memory change, I think
we need something like the following.

Frank, could you please give it a try?

Thanks,
Song

diff --git i/kernel/module/main.c w/kernel/module/main.c
index 0f9183f1ca9f..e4e723e1eb21 100644
--- i/kernel/module/main.c
+++ w/kernel/module/main.c
@@ -1514,14 +1514,14 @@ static void __layout_sections(struct module
*mod, struct load_info *info, bool i
                MOD_RODATA,
                MOD_RO_AFTER_INIT,
                MOD_DATA,
-               MOD_INVALID,    /* This is needed to match the masks array */
+               MOD_DATA,
        };
        static const int init_m_to_mem_type[] = {
                MOD_INIT_TEXT,
                MOD_INIT_RODATA,
                MOD_INVALID,
                MOD_INIT_DATA,
-               MOD_INVALID,    /* This is needed to match the masks array */
+               MOD_INIT_DATA,
        };

        for (m = 0; m < ARRAY_SIZE(masks); ++m) {
