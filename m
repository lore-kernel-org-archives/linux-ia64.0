From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 24 Oct 2003 17:42:40 +0000
Subject: RE: Itanium2@900MHz slower than alpha@666MHz ?
Message-Id: <marc-linux-ia64-106701811401790@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106700871121653@msgid-missing>
In-Reply-To: <marc-linux-ia64-106700871121653@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It wasn't clear from the description whether you actually turned on
profile guided optimization with electron compiler.  It is a two pass
compilation, once with -prof_gen to generate execution profile and then
once with -prof_use to complete PGO optimization.

One other neat thing about Itanium architecture is the capability of
it's performance counter.  It has capability to do cycle accounting that
break-down the number of cycles that are lost due to various kinds of
micro-architectural events, it is based on CPU's actual stall cycles in
the pipeline so you can see exactly where the stall is coming from to
eliminate any guess work.

See electron compiler user's guide for PGO methodology:
http://www.intel.com/software/products/compilers/c60l/resources/c_ug_lnx
.pdf

Cycle accounting is described in Intel Itanium Software developer's
manual.

- Ken


-----Original Message-----
From: linux-ia64-owner@vger.kernel.org
[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Ionut Georgescu
Sent: Friday, October 24, 2003 8:15 AM
To: linux-ia64@vger.kernel.org
Subject: Itanium2@900MHz slower than alpha@666MHz ?

Hello,

I am puzzled about the speed of a zx2000 workstation with a 900Mhz CPU.
According to the SPECfp2000 benchmarks, this workstation should be about
twice as fast as a DS10 alpha workstation and according to the fftw2
benchmarks at least 50% faster (double precision, real data, 256x256 FFT
transforms). I ran the fftw2 benchmark myself and I could reproduce the
data on fftw.org

However, my program is about 40% slower on the zx2000 as on the alpha.
It only does some Fourier transforms (fftw2, 256x256) and some matrix
operations (sort of an inner product). Both fftw2 and the program have
been compiled with ecc -O2 -ipo -limf. ecc is Version 7.1, Build
20030307.

Both the alpha and the Itanium2 run Debian stable and kernel 2.4.20.

Is there anything else I can do to improve performance ? I tried to some
profiling (CFLAGS="-g -p -Ob0 -O0 -inline_debug_info"), but the report
is missing the call-graph and a lot of other information, so that I
can't trust the quality of those data. Right now I'm trying to dig my
way through qprof and pfmon (for the moment qprof fails when
QPROF_HW_EVENT is set).

Thanks a lot,
Ionut

-- 
***************
* Ionut Georgescu
* http://www.physik.tu-cottbus.de/~george/
* Registered Linux User #244479
*
* "In Windows you can do everything Microsoft wants you to do; in Unix
you
*                can do anything the computer is able to do."

-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
