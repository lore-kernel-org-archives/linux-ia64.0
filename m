From: Andreas Schwab <schwab@suse.de>
Date: Fri, 20 Jun 2003 20:25:06 +0000
Subject: Re: 2.5.72 for ia64 released
Message-Id: <marc-linux-ia64-105614071827225@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105605890319553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105605890319553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

jbarnes@sgi.com (Jesse Barnes) writes:

|> On Fri, Jun 20, 2003 at 09:44:13PM +0200, Andreas Schwab wrote:
|> > jbarnes@sgi.com (Jesse Barnes) writes:
|> >=20
|> > |> This one Works For Me (tm).  Does it look ok?
|> >=20
|> > Does it require other patches?
|>=20
|> Yes, as it turns out.  You'll need the discontig patch I posted earlier.

These patches overlap.  I had to delete the arch/ia64/Kconfig patch from
the discontig patch.  Unfortunately, there are more problems
(devfs_handle_t is private to devfs):

  CC      arch/ia64/sn/io/drivers/ifconfig_net.o
arch/ia64/sn/io/drivers/ifconfig_net.c:40: error: parse error before "ifcon=
fig_net_handle"
arch/ia64/sn/io/drivers/ifconfig_net.c:40: warning: type defaults to `int' =
in declaration of `ifconfig_net_handle'
arch/ia64/sn/io/drivers/ifconfig_net.c:40: warning: data definition has no =
type or storage class
arch/ia64/sn/io/drivers/ifconfig_net.c: In function `init_ifconfig_net':
arch/ia64/sn/io/drivers/ifconfig_net.c:285: warning: assignment makes integ=
er from pointer without a cast
arch/ia64/sn/io/drivers/ifconfig_net.c:290: warning: assignment makes integ=
er from pointer without a cast
arch/ia64/sn/io/drivers/ifconfig_net.c:292: warning: comparison between poi=
nter and integer
make[3]: *** [arch/ia64/sn/io/drivers/ifconfig_net.o] Error 1

Thanks, Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
