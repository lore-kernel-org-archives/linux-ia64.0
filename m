From: Jes Sorensen <jes@trained-monkey.org>
Date: Thu, 03 Oct 2002 02:33:08 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.39)
Message-Id: <marc-linux-ia64-105590701906081@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

> >>>>> On Tue, 1 Oct 2002 09:28:12 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:
> 
>   Peter>       1.  Change the definition of ino_t to be a long, not an
>   Peter> int, as was done in the sparc64 and ppc64 code.  The comments
>   Peter> in asm/posix_types.h say these types are used for
>   Peter> communication to userspace, so maybe that's not an option any
>   Peter> more?
>
> [snip]
> 
> If we can do it without breaking apps, I'm all for changing ino_t to
> 64 bits.  Note that "struct stat" already defines the st_ino member as
> "unsigned long".  Also, glibc declares ino_t as a 64-bit type.

I don't think there should be many (if any) cases where this happens,
but I agree it should be validated. Since we're in little endian mode,
we might be lucky that natural data alignment inside structs will save
us as well ;-)

Cheers,
Jes

