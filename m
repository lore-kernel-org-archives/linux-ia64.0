From: Andreas Schwab <schwab@suse.de>
Date: Mon, 07 Jan 2002 16:31:51 +0000
Subject: Re: [Linux-ia64] PATCH redirectable IRQs
Message-Id: <marc-linux-ia64-105590698805757@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805756@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805756@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Erich Focht <efocht@ess.nec.de> writes:

|> @@ -234,9 +234,13 @@
|>  		writel(IOSAPIC_RTE_LOW(pin), addr + IOSAPIC_REG_SELECT);
|>  		low32 =3D readl(addr + IOSAPIC_WINDOW);
|> =20
|> -		/* change delivery mode to fixed */
|>  		low32 &=3D ~(7 << IOSAPIC_DELIVERY_SHIFT);
|> -		low32 |=3D (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
|> +		if (redir =3D=3D 1)

Just a nit: since redir is a boolean value it should be used as such.

|> diff -ur 2.4.17/arch/ia64/kernel/irq.c 2.4.17-irqr/arch/ia64/kernel/irq.c
|> --- 2.4.17/arch/ia64/kernel/irq.c	Mon Jan  7 11:35:08 2002
|> +++ 2.4.17-irqr/arch/ia64/kernel/irq.c	Mon Jan  7 12:45:17 2002
|> @@ -1090,13 +1090,15 @@
|>  static struct proc_dir_entry * smp_affinity_entry [NR_IRQS];
|> =20
|>  static unsigned long irq_affinity [NR_IRQS] =3D { [0 ... NR_IRQS-1] =3D=
 ~0UL };
|> +static char irq_redir [NR_IRQS] =3D { [0 ... NR_IRQS-1] =3D 1 };
|> =20
|>  static int irq_affinity_read_proc (char *page, char **start, off_t off,
|>  			int count, int *eof, void *data)
|>  {
|>  	if (count < HEX_DIGITS+1)
|>  		return -EINVAL;
|> -	return sprintf (page, "%08lx\n", irq_affinity[(long)data]);
|> +	return sprintf (page, "%s %08lx\n", irq_redir[(long)data] =3D=3D 1 ? "=
r" : "f",

Same here.

|> @@ -1104,11 +1106,20 @@
|>  {
|>  	int irq =3D (long) data, full_count =3D count, err;
|>  	unsigned long new_value;
|> +	char *buf =3D buffer;
|> +	int redir;
|> =20
|>  	if (!irq_desc(irq)->handler->set_affinity)
|>  		return -EIO;
|> =20
|> -	err =3D parse_hex_value(buffer, count, &new_value);
|> +	if (buf[0] =3D=3D 'r' || buf[0] =3D=3D 'R') {
|> +		++buf;
|> +		while (*buf =3D=3D ' ') ++buf;
|> +		redir =3D 1;
|> +	} else
|> +		redir =3D 0;
|> +
|> +	err =3D parse_hex_value(buf, count, &new_value);

Should this handle buf[0] =3D=3D 'f'?  You get this when you read the file,=
 so
someone will probably try to write in the same format.  Unfortunately this
conflicts with the use of hexadecimal for the cpu number, so
irq_affinity_read_proc should perhaps not output the 'f' prefix.

Andreas.

--=20
Andreas Schwab             SuSE Labs                  schwab@suse.de
SuSE GmbH, Deutschhherrnstr. 15-19, D-904229 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

