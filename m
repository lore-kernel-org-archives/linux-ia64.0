From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 16 Mar 2005 10:13:13 +0000
Subject: Re: __IA64_UNCACHED_OFFSET undefined...
Message-Id: <16952.1721.789470.547967@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <16951.36066.84031.81177@berry.gelato.unsw.EDU.AU>
In-Reply-To: <16951.36066.84031.81177@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jes" = Jes Sorensen <jes@wildopensource.com> writes:

>>>>> "Peter" = Peter Chubb <peterc@gelato.unsw.edu.au> writes:
Peter> Hi, Changeset
Peter> jes@wildopensource.com[torvalds]|ChangeSet|20050314001633|21074
Peter> introduced new functions into include/asm-ia64/uaccess.h, and
Peter> broke IA64 compilation.  I think it needs the attached
Peter> additional change:

Jes> I'm fine with the change, just curious what your config is - it
Jes> compiled fine for me when I pushed it.


Uniprocessor ZX1:  see http://www.gelato.unsw.edu.au/kerncomp
and
http://gelato.unsw.edu.au/kerncomp/results//2005-03-15-16-00/config-2.6.5-i2-uni-log.html


-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
