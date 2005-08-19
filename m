From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Fri, 19 Aug 2005 22:49:20 +0000
Subject: Re: debian/testing cannot compile static with gcc3.3.5
Message-Id: <17158.25072.945051.784334@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050819162011.GB6405@frankl.hpl.hp.com>
In-Reply-To: <20050819162011.GB6405@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Stephane" = Stephane Eranian <eranian@hpl.hp.com> writes:

Stephane> Hello, I recently upgraded my system to the latest testing.
Stephane> Since then, I cannot comile any program with static linking:

It's a glibc bug.  Get a glibc after 2.3.5.

See http://bugs.debian.org/cgi-bin/bugreport.cgi?bug19115

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
