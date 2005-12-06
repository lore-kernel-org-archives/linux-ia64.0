From: Andreas Schwab <schwab@suse.de>
Date: Tue, 06 Dec 2005 17:10:40 +0000
Subject: Re: Reading /proc/stat is slooow
Message-Id: <jeslt6xib3.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F05204A1E@scsmsx401.amr.corp.intel.com>
	<894E37DECA393E4D9374E0ACBBE7427003BC9642@pdsmsx402.ccr.corp.intel.com>
	<20051206165800.GA6277@agluck-lia64.sc.intel.com>
In-Reply-To: <20051206165800.GA6277@agluck-lia64.sc.intel.com> (Tony Luck's
	message of "Tue, 6 Dec 2005 08:58:00 -0800")
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Zou, Nanhai" <nanhai.zou@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:

> 2) The problem loop is already #ifdef'd out for PPC64 and ALPHA.  We coul=
d add
> IA64 to that exclusive club and just not include the per irq sums.  Since=
 kstat_irqs()
> computes the sums in an "int", they will wrap frequently on a large system
> (512 cpus * default 250Hz =3D 128000 ... which wraps a 32-bit unsigned in=
 9 hours
> and 19 minutes) ... so their usefulness is questionable.  Does xosview use
> the per-irq values?

It doesn't use them, it uses /proc/interrupts instead.  So IMHO this would
be the preferred solution.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
