From: Jes Sorensen <jes@wildopensource.com>
Date: Wed, 16 Mar 2005 11:02:55 +0000
Subject: Re: __IA64_UNCACHED_OFFSET undefined...
Message-Id: <yq07jk7zwdc.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16951.36066.84031.81177@berry.gelato.unsw.EDU.AU>
In-Reply-To: <16951.36066.84031.81177@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peterc@gelato.unsw.edu.au> writes:

>>>>> "Jes" = Jes Sorensen <jes@wildopensource.com> writes:
>>>>> "Peter" = Peter Chubb <peterc@gelato.unsw.edu.au> writes:
Peter> Hi, Changeset
Peter> jes@wildopensource.com[torvalds]|ChangeSet|20050314001633|21074
Peter> introduced new functions into include/asm-ia64/uaccess.h, and
Peter> broke IA64 compilation.  I think it needs the attached
Peter> additional change:

Jes> I'm fine with the change, just curious what your config is - it
Jes> compiled fine for me when I pushed it.

Peter> Uniprocessor ZX1: see http://www.gelato.unsw.edu.au/kerncomp
Peter> and

I assume it was just an old config you used? Anyway if you add a
signed-off-by I'll be happy to forward it to Linus.

Cheers,
Jes
