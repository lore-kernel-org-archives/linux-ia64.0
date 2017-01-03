From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Tue, 03 Jan 2017 21:25:28 +0000
Subject: Re: [PATCH v5 04/14] tables.h: add linker table support
Message-Id: <20170103212528.GE13946@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
 <20161222023811.21246-1-mcgrof@kernel.org>
 <20161222023811.21246-5-mcgrof@kernel.org>
 <1482415098.9552.123.camel@linux.intel.com>
In-Reply-To: <1482415098.9552.123.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>, hpa@zytor.com
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com

On Thu, Dec 22, 2016 at 03:58:18PM +0200, Andy Shevchenko wrote:
> On Wed, 2016-12-21 at 18:38 -0800, Luis R. Rodriguez wrote:
> > +#define LINKTABLE_FOR_EACH(pointer, tbl)			=09
>=20
> Hmm... SOMEONE LIKES CAPITAL LETTERS FOR everything, right? :-)
>
> I would expect more standard linktable_for_each() macro

hpa had recommended this, if he prefers a lower case I can change that
but I really do consider this bikeshedding.

> Same to the rest of similar macros.

Same answer here.

> > +/**
> > + * LINKTABLE_RUN_ERR - run each linker table entry func and return
> > error if any
> > + *
> > + * @tbl: linker table
> > + * @func: structure name for the function name we want to call.
> > + * @args...: arguments to pass to func
> > + *
> > + * Example usage::
> > + *
> > + *=A0=A0=A0unsigned int err =3D LINKTABLE_RUN_ERR(frobnicator_fns,
> > some_run,);
> > + */
> > +#define LINKTABLE_RUN_ERR(tbl, func, args...)			=09
> > \
> > +({								=09
> > \
> > +	size_t i;						=09
> > \
> > +	int err =3D 0;						=09
> > \
> > +	for (i =3D 0; !err && i < LINKTABLE_SIZE(tbl); i++)	=09
> > \
> > +		err =3D (LINKTABLE_START(tbl)[i]).func (args);	=09
>=20
>=20
> > \
> > +		err;						=09
>=20
> Indentation here a bit confusing.

Ah yes, good catch, fixed.

  Luis
