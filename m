From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 24 May 2006 21:45:54 +0000
Subject: RE: dropping CONFIG_IA32_SUPPORT from ia64
Message-Id: <17524.54290.859217.426866@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605241438.34303.bjorn.helgaas@hp.com>
In-Reply-To: <200605241438.34303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Tony Luck <Luck> writes:

BH>> 
BH>> Or maybe the people using ia32 compatibility are just running big
BH>> apps like Firefox or Open Office that are non-trivial to build for
BH>> ia64, but may not care as much about shiny new syscalls.

Tony> Firefox has been ported ... it came as a native ia64 binary rpm
Tony> on the last OSD install disk that I put on my workstation.
Tony> Dunno about Open office though.

Acrobat is the only thing I use it for...  and firefox when I *have*
to view flash movies.

I think that IA32 support is important for those (few) of us who use
Zx2000 or similar as workstations on Debian.  And I'm hoping that that
number will increase now that some of the 2nd generation clusters are
reaching eol, so there should be starting to be zx6000 on the 2nd hand
market relatively cheap.  I've seen a few here for $1300AUD --- and
even as old (1.2GHz) machines they beat the pants off anything else
you can buy here at that price.

The new system calls are irrelevant for most apps.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
