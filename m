From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 01 Sep 2004 05:59:33 +0000
Subject: Bad interaction between virtual memmap and rmap changes?
Message-Id: <20040901055933.GC21873@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="2fHTh5uZTiUOsy+g"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

With 2.6.9-rc1 on IA64 I have this problem when I boot on an rx2600
(with both SMP and uniprocessor builds) :

Bad page state at free_hot_cold_page (in process 'swapper', page e0000000049bcd08)
flags:0x00000000 mapping:0000000000000000 mapcount:1 count:0
Backtrace:
[-- no backtrace is printed, unfortunately, and the machine stops dead --]

But I also noticed that virtual mem map was right at around the same
place :

Virtual mem_map starts at 0xe000000004928000

So I turned that off in the config, and it appears to work OK.  I
noticed there were a lot of rmap changes with respect to locking just
recently put in, and I suspect they are the culprit.  I'm afraid this
is a little over my head, but I'm willing to try any suggestions.

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

--2fHTh5uZTiUOsy+g
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBNWVFWDlSU/gp6ecRAiixAKDc8hn0S+EyshCT904Zlr/wizC9qACfaRb5
RSnmF4aedCKnqV0ZHfOkZ3Q=
=dtI2
-----END PGP SIGNATURE-----

--2fHTh5uZTiUOsy+g--
