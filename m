From: Roy Dragseth <Roy.Dragseth@cc.uit.no>
Date: Mon, 13 Jan 2003 09:37:53 +0000
Subject: [Linux-ia64] Problem solved (was: disabling nics in efi.)
Message-Id: <marc-linux-ia64-105590709805668@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi.

HP-Support suggested that we tried to disable something called the spanning=
=20
tree algorithm on the switch.   We did, and voila the problem disappeared. =
=20
The spanning tre algorithm has a very long timeout, 30 seconds.

So, for our part the problem is solved, but the timeout issue might be wort=
h=20
solving on a general basis.

Thanks for all the insightful suggestions from you people on this list.  Th=
is=20
problem might be a bit mundane and not very ia64 specific, compared to what=
=20
I've seen on this list before, so I'm sorry if this thread has wasted=20
knowlegdable peoples time.

Regards,
Roy.

--=20

  The Computer Center, University of Troms=F8, N-9037 TROMS=D8, Norway.
	      phone:+47 77 64 41 07, fax:+47 77 64 41 00
     Roy Dragseth, High Performance Computing System Administrator
	 Direct call: +47 77 64 62 56. email: royd@cc.uit.no


