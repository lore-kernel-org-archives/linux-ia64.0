From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 29 Jan 2003 17:10:07 +0000
Subject: RE: [Linux-ia64] kernel update (relative to 2.5.59)
Message-Id: <marc-linux-ia64-105590709805768@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I had the same problem with mconf when I built with 2.96 (it just
printed the name of the Kconfig file and exited with status 1,
strace didn't show any unexpected system call failures).

I got a successful build using gcc 3.1 (well after I did

	s/.owner = THIS_MODULE;/.owner = THIS_MODULE,/

in a couple of the drivers/char/agp/*.c)

I'm now up and running on a BigSur.

-Tony

> -----Original Message-----
> From: Erich Focht [mailto:efocht@ess.nec.de]
> Sent: Wednesday, January 29, 2003 6:06 AM
> To: davidm@hpl.hp.com
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] kernel update (relative to 2.5.59)
> 
> 
> On Saturday 25 January 2003 06:02, David Mosberger wrote:
> > Oh, most importantly: you'll need a new assembler in order 
> to use this
> > patch.  There was a nasty bug up until Dec 18 last year which
> > basically made certain place-relative expressions generate bad data.
> > Fortunately, HJ Lu has fixed that bug and I put a 
> read-for-use, static
> > binary of a fixed assembler at:
> >
> > 	ftp://ftp.hpl.hp.com/pub/linux-ia64/gas-030124.tar.gz
> >
> > As a measure of safety, I added a sanity check which will 
> cause "make"
> > to refuse to build a kernel with a buggy assembler.
> 
> David,
> 
> which gcc are you using? If I replace "as" with yours, I can't even
> "make menuconfig" or "make config". Tried with gcc 2.96 (from RedHat
> 7.2) and a self compiled gcc 3.2. The executable (mconf) fails. If I
> compile the kernel with the new "as", it doesn't boot. Am I the only
> one having this problem?
> 
> Regards,
> Erich
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

