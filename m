From: Andreas Jaeger <aj@suse.de>
Date: Tue, 18 Sep 2001 08:34:50 +0000
Subject: [Linux-ia64] Re: PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805199@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

George, you forgot to add the appended part.  Especially the paragraph
is important that this will not imply a binary incompatible change for
ia64, ia64 has an emulation for 32-bit binaries but is not a real
32/64-bit platform like Sparc64, x86-64, PPC64 and S390.

David, does this satisfy your ia64 concerns?

Andreas

3. Recommendations

   We recommend the use of /lib64 to contain the 64bit
   libraries on multi-library capable 64bit Linux ports and a
   /lib which isn't a symbolic link but a real directory to
   contain 32bit libraries for the following reasons:

   * existing 32bit applications will install with rpm directly
     and run without a change in a 64bit system (zSeries and
     sparc64 today)

   * rpm is known to fail on nested symlinks within in pathes
     on updating those directories; therefore /lib should not
     be a link to /lib32.

   * dedicated directory structure for a 32bit subsystem does
     not integrate smoothly into the existing FHS / (root)
     directory structure. FHS today does not allow new
     directories below / (root). Possible options would be
     /opt/emu32, /usr/emu32 ... rpm needs to install
     accordingly, too, but will not work with todays versions
     (this could be achieved with intelligent wrapper scripts
     analysing the target system but this does not reflect a
     generic approach). Addtional problems might show up since
     /opt might not be available when booting up the system.

   * existing commercial binary-only applications like
     middleware and applications are and might only be
     available as 32-bit binaries for the time being due to
     porting efforts and quality assurance cycles.

   * exisiting binary executable code generating tool chain
     (gcc, binutils, glibc) already are capable to handle the
     /lib64 approach

   * /lib: consistent scheme for all 32bit systems and x86-64,
     sparc64, ppc64, zSeries (s390x).

   * iA64 today has a 32bit emulation mode, but 64bit is the
     (only) favored one; Alpha is too long established. (64bit
     libs will go to /lib)

   * only few applications or middleware will benefit from full
     64bit support in general (databases, ERP systems,
     applications using large memory caches for speed, numeric
     intense applications, ...)

   * 32bit applications tend to have a smaller memory footprint
     due code/data alignment in physical memory, thus total
     memory usage is more efficient on large systems with
     multiple Linux system instances (iSeries, zSeries)

   * compiler and toolchain can be used to build 32-bit
     applications on a 64-bit architecture; they can be
     transferred to 32-bit architecture hardware (cross
     development with tested executables) without further
     changes.

-- 
 Andreas Jaeger
  SuSE Labs aj@suse.de
   private aj@arthur.inka.de
    http://www.suse.de/~aj

