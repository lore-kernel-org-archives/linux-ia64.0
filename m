From: Andreas Schwab <schwab@suse.de>
Date: Thu, 03 Jun 2004 20:51:57 +0000
Subject: Re: GLIBC IA64 HP_TIMING fixes for SMP systems with unsynchronized
Message-Id: <je65a8e55e.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406031313420.32412@server.home>
In-Reply-To: <Pine.LNX.4.58.0406031313420.32412@server.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Christoph Lameter <christoph@lameter.com> writes:

> +ifeq ($(subdir),malloc)
> +libmemusage-routines +=3D hp-timing
> +endif

That needs to be libmemusage-sysdep_routines.

> +		int fd =3D open ("/proc/sal/itc_drift", O_RDONLY);

This is Linux-specific, isn't it?  Thus it belongs under
sysdeps/.../linux/ia64.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
