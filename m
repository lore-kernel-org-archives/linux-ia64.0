From: Christoph Rohland <cr@sap.com>
Date: Tue, 09 May 2000 16:52:19 +0000
Subject: Re: [Linux-ia64] ld failure
Message-Id: <marc-linux-ia64-105590678205074@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205047@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205047@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Jim,

Jim Wilson <wilson@cygnus.com> writes:
> #3 seems like the most likely explanation.  We would need a complete test=
case
> to reproduce this, which means a copy of all object files and
> libraries that you are linking together, together with the linker
> command line.  Fixing this would be a low priority, so it may be a
> few weeks before it gets fixed.

This problem is solved with the new gnupro toolkit included on TL
0505. (Of course I get now an =EDllegal instruction'when running the
executable due to the missing brl emulation in the kernel.)

Keep up the good work!

		Christoph


