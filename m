From: Michael Cree <mcree@orcon.net.nz>
Date: Thu, 10 Jan 2019 23:14:31 +0000
Subject: Re: [PATCH 00/15] arch: synchronize syscall tables in preparation for y2038
Message-Id: <20190110231431.ho6mjhjkj4p47hww@tower>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190110162435.309262-1-arnd@arndb.de>
 <alpine.DEB.2.21.1901101808220.31458@digraph.polyomino.org.uk>
 <CAK8P3a2f4SCJXrm6HWO9UKY-akSW+ONNpOvQOtYbia_fRo9ciQ@mail.gmail.com>
In-Reply-To: <CAK8P3a2f4SCJXrm6HWO9UKY-akSW+ONNpOvQOtYbia_fRo9ciQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dominik Brodowski <linux@dominikbrodowski.net>, linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Deepa Dinamani <deepa.kernel@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux <sparclinux@vger.kernel.org>, Joseph Myers <joseph@codesourcery.com>, linux-s390 <linux-s390@vger.kernel.org>, Davidlohr Bueso <dave@stgolabs.net>, y2038 Mailman List <y2038@lists.linaro.org>, Michael Ellerman <mpe@ellerman.id.au>, Helge Deller <deller@gmx.de>, the arch/x86 maintainers <x86@kernel.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Firoz Khan <firoz.khan@linaro.org>, Matt Turner <mattst88@gmail.com>

On Thu, Jan 10, 2019 at 11:42:32PM +0100, Arnd Bergmann wrote:
> On Thu, Jan 10, 2019 at 7:10 PM Joseph Myers <joseph@codesourcery.com> wrote:
> >
> > On Thu, 10 Jan 2019, Arnd Bergmann wrote:
> >
> > > - Add system calls that have not yet been integrated into all
> > >   architectures but that we definitely want there.
> >
> > glibc has a note that alpha lacks statfs64, any plans for that?
> 
> Good catch, I missed that because all other 64-bit architectures
> have a statfs() call with 64-bit fields. I see that it also has an
> osf_statfs64 structure and system call with lots of padding and some
> oddly sized fields: f_type, f_flags and f_namemax are only 16 bits
> wide, the rest is all 64-bit.
> 
> Adding the regular statfs64() should be easy enough, we just need to
> decide which layout to use:
> 
> a) use the currently unused 'struct statfs64' as provided by the
>     alpha uapi headers, which has a 32-bit __statfs_word but
>     64-bit f_blocks, f_bfree, f_bavail, f_files, and f_ffree.
> 
> b) copy asm-generic/statfs.h to the alpha asm/statfs.h and
>     change statfs64 to have the regular layout that we use
>     on all other 64-bit architectures, using all 64-bit fields.
> 
> The other open question for alpha (as mentioned in one of the
> patches I sent) would be whether to add get{eg,eu,g,p,pp,u}id()
> with the regular calling conventions.

I would be interested in seeing those provided on Alpha.  There are
a handful of projects choosing to sidestep glibc for these syscalls
and they break on Alpha.  Such projects are never keen to include
special assembler code (because the extant syscalls on Alpha are not
C ABI compliant) to support a legacy arch.

Cheers
Michael.
