From: Joseph Landman <landman@scalableinformatics.com>
Date: Sat, 12 Apr 2003 23:16:03 +0000
Subject: [Linux-ia64] Re: HPL Benchmark on Itanium 2 box
Message-Id: <marc-linux-ia64-105590723705489@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Brent:

  Looks like either a missing library, or a library order issue. The
HPL_pdtest.o is trying to find the cblas_dgemv function.  This function
is likely supplied in the optimized Intel libs (though I don't know
which library, but it would be one supplying BLAS and LAPACK routines
optimized for the platform).  You may have a -L/path in front of the
correct -lcblas (or similar library name).  If you can find out which
library is supposed to provide that function, try moving it to a
different position in the link line.

Joe

On Sat, 2003-04-12 at 12:06, Brent M. Clements wrote:
> Hi Guys,
> I'm trying to compile the hpl benchmark on a HP zx6000 box.
> 
> I have the hp math libraries and the intel 7.0 compilers.
> 
> Has anyone ever tried compiling the hpl benchmark using this compile
> configuration? If so could they send me their Makefile
> 
> The reason I'm asking is because I keep on getting the following error
> 
> HPL_pdtest.o: In function `HPL_pdtest':
> HPL_pdtest.o(.text+0x1a82): undefined reference to `cblas_dgemv'
> HPL_pdtest.o(.text+0x1ad2): undefined reference to `cblas_dgemv'
> 
> Anyone have a clue?
> 
> Thanks,
> 
> 
> Brentr Clements
> 
> 
> _______________________________________________
> Beowulf mailing list, Beowulf@beowulf.org
> To change your subscription (digest mode or unsubscribe) visit http://www.beowulf.org/mailman/listinfo/beowulf
-- 
Joseph Landman, Ph.D
Scalable Informatics LLC
email: landman@scalableinformatics.com
  web: http://scalableinformatics.com
phone: +1 734 612 4615


