From: Jes Sorensen <jes@wildopensource.com>
Date: Wed, 16 Mar 2005 09:52:53 +0000
Subject: Re: __IA64_UNCACHED_OFFSET undefined...
Message-Id: <yq0k6o7zzm2.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16951.36066.84031.81177@berry.gelato.unsw.EDU.AU>
In-Reply-To: <16951.36066.84031.81177@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peterc@gelato.unsw.edu.au> writes:

Peter> Hi, Changeset
Peter> jes@wildopensource.com[torvalds]|ChangeSet|20050314001633|21074
Peter> introduced new functions into include/asm-ia64/uaccess.h, and
Peter> broke IA64 compilation.  I think it needs the attached
Peter> additional change:

I'm fine with the change, just curious what your config is - it
compiled fine for me when I pushed it.

Cheers,
Jes
