From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Mon, 21 Nov 2005 16:08:42 +0000
Subject: Re: Fix asm constraint in put_user
Message-Id: <ed5aea430511210808w125f5640sb4ca52a9972bd6c1@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je7jb2nigc.fsf@sykes.suse.de>
In-Reply-To: <je7jb2nigc.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

If memory services, you should use the "o" constraint instead.  Note
that there is no "memory" clobber, so if you change from "m" to "r"
constraint, GCC won't know that the location at "addr" is being stored
to.

  --david

On 11/21/05, Andreas Schwab <schwab@suse.de> wrote:
> The st insn on the ia64 does not allow the post-increment to come from a
> register (only ld does).  Thus the "m" constraint is not suitable for the
> asm statement in __put_user_size.
>
> Signed-off-by: Andreas Schwab <schwab@suse.de>
>
> --- linux-2.6.14/include/asm-ia64/uaccess.h.~1~ 2005-10-28 02:02:08.00000=
0000 +0200
> +++ linux-2.6.14/include/asm-ia64/uaccess.h     2005-11-20 18:15:46.55929=
6784 +0100
> @@ -154,10 +154,10 @@ do {                                               =
                                               \
>  # define __put_user_size(val, addr, n, err)                             =
                       \
>  do {                                                                    =
                       \
>         register long __pu_r8 asm ("r8") =3D 0;                          =
                         \
> -       asm volatile ("\n[1:]\tst"#n" %1=3D%r2%P1\t// %0 gets overwritten=
 by exception handler\n" \
> +       asm volatile ("\n[1:]\tst"#n" [%1]=3D%r2\t// %0 gets overwritten =
by exception handler\n"  \
>                       "\t.xdata4 \"__ex_table\", 1b-., 1f-.\n"           =
                       \
>                       "[1:]"                                             =
                       \
> -                     : "=3Dr"(__pu_r8) : "m"(__m(addr)), "rO"(val), "0"(=
__pu_r8));               \
> +                     : "=3Dr"(__pu_r8) : "r"(addr), "rO"(val), "0"(__pu_=
r8));            \
>         (err) =3D __pu_r8;                                               =
                         \
>  } while (0)
>
>
> Andreas.
>
> --
> Andreas Schwab, SuSE Labs, schwab@suse.de
> SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
> PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
> "And now for something completely different."
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


--
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
