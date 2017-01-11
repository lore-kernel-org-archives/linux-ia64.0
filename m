From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Wed, 11 Jan 2017 14:37:22 +0000
Subject: Re: [PATCH v6 00/14] linux: generalize sections, ranges and linker tables
Message-Id: <20170111143722.GM13946@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161222023811.21246-1-mcgrof@kernel.org>
 <20170109145833.11502-1-mcgrof@kernel.org>
 <1483979228.26691.40.camel@linux.intel.com>
 <1483981946.26691.44.camel@intel.com>
 <1483986555.26691.46.camel@linux.intel.com>
In-Reply-To: <1483986555.26691.46.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vr

On Mon, Jan 09, 2017 at 08:29:15PM +0200, Andy Shevchenko wrote:
> On Mon, 2017-01-09 at 19:12 +0200, Andy Shevchenko wrote:
> > On Mon, 2017-01-09 at 18:27 +0200, Andy Shevchenko wrote:
> > > On Mon, 2017-01-09 at 06:58 -0800, Luis R. Rodriguez wrote:
> > > > The only architecture that was not tested was avr32 and that is
> > > > because
> > > > linux-next fails to compile on it. I'd like to greatly thank
> > > > Guenter
> > > > Roeck for
> > > > his help with testing.
> > >=20
> > > We have a real board here. I would try to check if you provide a git
> > > url
> > > to your stuff.
> > >=20
> > > I can confirm that breakage happened like in last couple of month.
> > > v4.10-rc3 can't be compiled either.
> >=20
> > The culprit commit is
> >=20
> > commit 3a0af8fd61f90920f6fa04e4f1e9a6a73c1b4fd2
> > Author: Thomas Graf <tgraf@suug.ch>
> > Date:=A0=A0=A0Wed Nov 30 17:10:10 2016 +0100
> >=20
> > =A0=A0=A0=A0bpf: BPF for lightweight tunnel infrastructure
> >=20
>=20
> This makes modules closer to each other, so,
> net/socket.c:348: relocation truncated to fit: R_AVR32_11H_PCREL against
> `.text'+2930
>=20
> But still the module is too big for AVR to do some jumps.

Well I've reverted your patch and tested on avr32 and all tests
worked successfully. Thanks to Guenter again for helping with his
testbed once again!

  Luis
