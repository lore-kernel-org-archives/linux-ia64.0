From: Joe Perches <joe@perches.com>
Date: Thu, 21 Sep 2017 02:28:33 +0000
Subject: Re: [RFC][PATCH v2 7/7] checkpatch: add pF/pf deprecation warning
Message-Id: <1505960913.12311.18.camel@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170920162910.32053-1-sergey.senozhatsky@gmail.com>
         <20170920162910.32053-8-sergey.senozhatsky@gmail.com>
         <1505929138.12311.5.camel@perches.com>
         <20170921002717.GA773@jagdpanzerIV.localdomain>
In-Reply-To: <20170921002717.GA773@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@canonical.com>

On Thu, 2017-09-21 at 09:27 +0900, Sergey Senozhatsky wrote:
> On (09/20/17 10:38), Joe Perches wrote:
> > On Thu, 2017-09-21 at 01:29 +0900, Sergey Senozhatsky wrote:
> > > We deprecated '%pF/%pf' printk specifiers, since '%pS/%ps' is now sma=
rt
> > > enough to handle function pointer dereference on platforms where such
> > > dereference is required.
> > >=20
> > > checkpatch warning example:
> > >=20
> > > WARNING: Use '%pS/%ps' instead. This pointer extension was deprecated=
: '%pF'
> >=20
> > If this series is accepted,  I think this message
> > is unclear and would prefer something like:
>=20
> sure, can tweak the patch.
>=20
> [..]
> > =A0			if ($bad_extension ne "") {
> > =A0				my $stat_real =3D raw_line($linenr, 0);
> > +				my $ext_type =3D "Invalid";
> > +				my $use =3D "";
> > =A0				for (my $count =3D $linenr + 1; $count <=3D $lc; $count++) {
> > =A0					$stat_real =3D $stat_real . "\n" . raw_line($count, 0);
> > =A0				}
> > +				if ($bad_extension =3D~ /p[Ff]/i) {
>=20
> 						I think /i is not necessary here

You are right, it's not.

