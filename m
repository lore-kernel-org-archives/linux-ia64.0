From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 01 Aug 2002 08:18:27 +0000
Subject: [Linux-ia64] 2.5.29 pre-patch
Message-Id: <marc-linux-ia64-105590701905875@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

For those of you who want to play with the latest 2.5.xx kernels urgently,
I placed a lightly tested patch at:

	ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/testing/

in file patch-v2.5.29-ia64.diff.

Note: this patch is unusually large (~800KB) because it also contains
the stuff the Linus has pushed into the bitkeeper tree after releasing
2.5.29.

With this patch, 2.5.29 seems to boot fine on the Ski simulator (UP and MP)
and on Itanium 1 workstations (aka Big Sur).  I haven't tried much else.

Caveats:

	- the ia64-specific AGP/DRM patches have not been merged yet,
	  so for now you'll have to turn those off

	- gcc3.1 dies for me with an ICE on ide-floppy.c; haven't had time
	  to look into this one

	- expect to have to do some cli/sti cleanup, depending on which
	  driver you're using

I still have a long list of things to check/update/verify, so this is
certainly not the final 2.5.29 patch for ia64, but perhaps it's
already useful to others in its current form.

One request: I'd appreciate if someone (Jenna?) could take a look at
the changes I made to mca.c.  It was using cli() and I'm not sure what
the purpose of it was.  Thus my changes may be wrong.

	--daivd

