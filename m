From: Matthew Wilcox <willy@debian.org>
Date: Fri, 24 Oct 2003 15:35:43 +0000
Subject: Re: Itanium2@900MHz slower than alpha@666MHz ?
Message-Id: <marc-linux-ia64-106700990423410@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106700871121653@msgid-missing>
In-Reply-To: <marc-linux-ia64-106700871121653@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 24, 2003 at 05:14:50PM +0200, Ionut Georgescu wrote:
> I am puzzled about the speed of a zx2000 workstation with a 900Mhz CPU.
> According to the SPECfp2000 benchmarks, this workstation should be about
> twice as fast as a DS10 alpha workstation and according to the fftw2
> benchmarks at least 50% faster (double precision, real data, 256x256 FFT
> transforms). I ran the fftw2 benchmark myself and I could reproduce the
> data on fftw.org
> 
> However, my program is about 40% slower on the zx2000 as on the alpha.
> It only does some Fourier transforms (fftw2, 256x256) and some matrix
> operations (sort of an inner product). Both fftw2 and the program have
> been compiled with ecc -O2 -ipo -limf. ecc is Version 7.1, Build
> 20030307.

This strikes me as possibly being a cache size thing.  Do you have the
1.5MB cache or 3MB cache version of the 900MHz Itanium?  The DS10 specs
I found at
http://www.spec.org/cpu2000/results/res2000q3/cpu2000-20000630-00134.asc
say it has a 2MB cache, so if your data set fits in a 2MB cache and not
in a 1.5MB cache, that would be a possible cause.

What kind of fluctuations do you see between runs?  Linux doesn't
do cache-colouring, so high variation between runs could indicate a
close-to-edge-of-cache scenario.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
