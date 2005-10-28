From: Roy Dragseth <Roy.Dragseth@cc.uit.no>
Date: Fri, 28 Oct 2005 11:18:51 +0000
Subject: Probing for physical number of cpus.
Message-Id: <200510281318.51532.Roy.Dragseth@cc.uit.no>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi.

Do anyone know how to figure out the physical number of cpus in an ia64=20
system?  No, /proc/cpuinfo wont do because the kernel is booted with=20
maxcpus=3D1.

When installing RH EL the install kernel is booted with maxcpus=3D1 and I n=
eed=20
to figure out the physical number of cpus in the system for later use in th=
e=20
software setup.  I need to be able to get this from userspace.

Any hints is greatly appreciated.

Regards,
r.

--=20

  The Computer Center, University of Troms=F8, N-9037 TROMS=D8 Norway.
	      phone:+47 77 64 41 07, fax:+47 77 64 41 00
     Roy Dragseth, High Performance Computing System Administrator
	 Direct call: +47 77 64 62 56. email: royd@cc.uit.no
