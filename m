From: Andreas Schwab <schwab@suse.de>
Date: Mon, 08 Dec 2003 16:25:27 +0000
Subject: Re: gcc builtin memcpy is bogus?
Message-Id: <marc-linux-ia64-107090077530283@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107090003129207@msgid-missing>
In-Reply-To: <marc-linux-ia64-107090003129207@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Matthew Wilcox <willy@debian.org> writes:

> This is a fun one ... I don't know what to blame for this.
>
> struct rfd {
>         u16 status;
>         u16 command;
>         u32 link;
>         u32 rbd;
>         u16 actual_size;
>         u16 size;
> };
>
> static void e100_rx_rfa_add_tail(struct nic *nic, struct rx_list *curr)
> {
>         struct rfd *rfd =3D (struct rfd *)curr->skb->data;
>        =20
>         memcpy(rfd, &nic->blank_rfd, sizeof(struct rfd));
> }
>
> I'm using gcc (GCC) 3.3.2 (Debian) for this.
>
> The kernel doesn't use -fno-builtin or -fno-builtin-memcpy so it attempts
> to optimise this by doing 4-byte loads and stores.  Problem is, the
> destination is misaligned (deliberately), so the kernel emits unaligned
> messages.  Adding -fno-builtin to the command line turns this back into
> a call to memcpy.
>
> So how should this be fixed?
>
>  - Improve gcc's builtin memcpy to work on non-aligned structs (unlikely)?

The builtin memcpy is correct, casting unaligned data is invoking
undefined behaviour here.

>  - Somehow tag the pointer or the struct that it's unaligned?
>  - Compile with -fno-builtin-memcpy (and probably a few others too)?
>
> Other suggestions?

- Don't use the casted address, but rather the original pointer in the
  memcpy call.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
