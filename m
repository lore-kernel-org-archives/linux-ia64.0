From: Roy Dragseth <royd@cc.uit.no>
Date: Fri, 10 Jan 2003 21:39:35 +0000
Subject: Re: [Linux-ia64] Re: Re: disabling nics using boot options.
Message-Id: <marc-linux-ia64-105590709805664@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805661@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805661@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I've done some more investigation into this matter, it seems like the whole=
=20
problem stems from a timing issue:

I reconfigured the Gbit interface to use a static ip-adress, but the proble=
m=20
persisted: The interface comes up seemingly all right during the init proce=
ss=20
in the normal bootup sequence, but the subsequent ypbind fail to find any=20
ypservers. =20

So, the problem doesn't have anything to do with dhcp, at least, so it seem=
s=20
to me.  But, if I put in a sleep 60 after ifup in the /etc/init.d/network=20
script, everything is ok. =20

To me, an illiterate when it comes to drivers and network hardware, it seem=
s=20
like the network card (or driver) needs some time to get ready to serve aft=
er=20
beeing configured.  Again, the problem only occurs when running Gbit, it=20
never shows up when I connect to a 100Mbit switch.

Well, I think I've pulled enough hair out of my head over this.  I'll just =

have to bite the bullet and rig all the machines with an extra cable and us=
e=20
the 100Mbit interface for the network installs.  Another day of stretching =

cables, sigh...

A big thanks to all who have replied to me with suggestions, especially Bil=
l.

r.


--=20

  The Computer Center, University of Troms=F8, N-9037 TROMS=D8, Norway.
	      phone:+47 77 64 41 07, fax:+47 77 64 41 00
     Roy Dragseth, High Performance Computing System Administrator
	 Direct call: +47 77 64 62 56. email: royd@cc.uit.no


