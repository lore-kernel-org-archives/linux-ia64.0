From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 27 May 2023 19:34:10 +0000
Subject: Re: Boot regression in Linux v6.4-rc3
Message-Id: <CAHk-=wjDQZ8snU__Y8qJ8M5H--1FtAwNq-oHKmY4CJuomWPvDw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
In-Reply-To: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Sat, May 27, 2023 at 11:41=E2=80=AFAM Frank Scheiner <frank.scheiner@web=
.de> wrote:
>
> Ok, I put the decoded console messages on [2].
>
> [2]: https://pastebin.com/dLYMijfS

Ugh. Apparently ia64 decoding isn't great. But at least it gives
multiple line numbers:

   load_module (kernel/module/main.c:2291 kernel/module/main.c:2412
kernel/module/main.c:2868)

except your kernel obviously has those test-patches, so I still don't
know exactly where they are.

But it looks like it is in move_module(). Strange. I don't know how it
gets to "__copy_user" from there...

[ Looks at the ia64 code ]

Oh.

It turns out that it *says* __copy_user(), but the code is actually
shared with the regular memcpy() function, which does

  GLOBAL_ENTRY(memcpy)
        and     r28=3D0x7,in0
        and     r29=3D0x7,in1
        mov     f6=3Df0
        mov     retval=3Din0
        br.cond.sptk .common_code
        ;;

where that ".common_code" label is - surprise surprise - the common
copy code, and so when the oops reports that the problem happened in
__copy_user(), it actually is in this case just a normal memcpy.

Ok, so it's probably the

        memcpy(dest, (void *)shdr->sh_addr, shdr->sh_size);

in move_module() that takes a fault.  And looking at the registers,
the destination is in r17/r18, and your dump has

    unable to handle kernel paging request at virtual address 1000000000000=
000
    ...
    r17 : 0fffffffffffffff r18 : 1000000000000000

so it's almost certainly that 'dest' that is bad.

Which I guess shouldn't surprise anybody.

But that's where my knowledge of ia64 and the new module loader layout ends.

                Linus
