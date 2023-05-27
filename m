From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 27 May 2023 17:08:24 +0000
Subject: Re: Boot regression in Linux v6.4-rc3
Message-Id: <CAHk-=whv0Mr_Gnwbm00vi76oTTw16KviVhC33segbjjZbxOswA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
In-Reply-To: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Sat, May 27, 2023 at 12:01=E2=80=AFAM Frank Scheiner <frank.scheiner@web=
.de> wrote:
>
> If it is of any help, my initial report is available for example via:
>
> https://marc.info/?l=3Dlinux-ia64&m=3D168509859125505&w=3D2
>
> ...the whole thread is currently at:
>
> https://marc.info/?t=3D168509868200003&r=3D1&w=3D2

This does make it clear just how great a mailing list archive lore is.
Konstantin, is there any particular reason why
linux-ia64@vger.kernel.org isn't in lore? Is it just a rational hatred
of all things itanium?

Anyway, the WARN_ON() is likely related, but the bug is clearly an
unexpected page fault in __copy_user() when called by load_module().

The ia64 oops output is nasty, presumably because ia64 aggressively
inlines things. It would help a lot if you enabled debug info (maybe
you already do?) and then run the oops through
./scripts/decode_stacktrace.sh which will figure out line numbers,
inlining etc.

Because I don't even see why it would call __copy_user() in the first
place. This is 'finit_module()' that loads the module data from a
file, not user space.

So I guess it must be the strndup_user() in

        mod->args =3D strndup_user(uargs, ~0UL >> 1);

but that doesn't look like it should even care about any module
layout. Plus I would have expected to see strndup_user() in the call
trace, but whatever.

End result: that ia64 trace is very hard to read, and _maybe_ running
it through the decode script might give more information about what it
is that triggers...

             Linus
