From: Andreas Schwab <schwab@suse.de>
Date: Fri, 20 Feb 2009 12:50:44 +0000
Subject: Re: [PATCH] IA64: cast has a higher precedence than '?'
Message-Id: <je3ae9l1az.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <499E998C.9060407@gmail.com>
In-Reply-To: <499E998C.9060407@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Roel Kluin <roel.kluin@gmail.com> writes:

> diff --git a/arch/ia64/include/asm/syscall.h b/arch/ia64/include/asm/sysc=
all.h
> index 2f758a4..3fc1832 100644
> --- a/arch/ia64/include/asm/syscall.h
> +++ b/arch/ia64/include/asm/syscall.h
> @@ -64,7 +64,7 @@ static inline void syscall_set_return_value(struct task=
_struct *task,
>  {
>  #ifdef CONFIG_IA32_SUPPORT
>  	if (IS_IA32_PROCESS(regs)) {
> -		regs->r8 =3D (long) error ? error : val;
> +		regs->r8 =3D (long) (error ? error : val);

The cast can be removed, it has no influence whatsoever.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
