From: Andreas Schwab <schwab@suse.de>
Date: Mon, 18 Aug 2003 16:05:26 +0000
Subject: Re: 2.6.0-test3: #undef SMP && #define NUMA does not compile
Message-Id: <marc-linux-ia64-106122298229493@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106122187228169@msgid-missing>
In-Reply-To: <marc-linux-ia64-106122187228169@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Matthew Wilcox <willy@debian.org> writes:

|> On Mon, Aug 18, 2003 at 05:46:17PM +0200, Andreas Schwab wrote:
|> > When configuring 2.6.0-test3 with CONFIG_SMP disabled and CONFIG_NUMA
|> > enabled I get undefined references to cpu_to_node_map and
|> > node_to_cpu_mask.  Both variables are defined in
|> > arch/ia64/kernel/smpboot.c, thus only available for SMP.
|>=20
|> Surely we should make NUMA depend on SMP?  Or does someone have an
|> example of a NUMA single-processor box ;-)

One might want to boot an UP kernel on a NUMA box, would that still work?

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
