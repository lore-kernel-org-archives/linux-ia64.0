From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 24 Jan 2001 23:27:05 +0000
Subject: Re: [Linux-ia64] Announce: IA-64 cross compiler on IA-32 available
Message-Id: <marc-linux-ia64-105590693005091@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005089@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005089@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, 24 Jan 2001 10:49:39 -0700 (MST),=20
Khalid Aziz <khalid@lyra.fc.hp.com> wrote:
>I recently built the latest version of IA-64 cross compiler on IA-32
>with all of the patches that have been posted on this mailing list. I
>have made the binaries available at
><ftp://puffin.external.hp.com/pub/ia64/gcc-2.96-ia64-000717-snap001117-bui=
ld2.tar.gz>.
>The compiler is configured to be installed under /opt/ia64. I have built
>and tested kernels with it. I have also built a few applications which
>worked. Let me know if anything is missing from this package.

This version of gcc invokes 'as' without a path name so it picks up the
standard ia32 assembler instead of the cross assembler.  This is
strange, it invokes 'cc1' with the correct path but not 'as'.

/opt/ia64/bin/ia64-cygnus-linux-gcc -v -D__KERNEL__ -I/build/kaos/2.4.0-kdb=
-ia64/include -Wall -Wstrict-prototypes -O2  -fno-strict-aliasing -fomit-fr=
ame-pointer -pipe  -ffixed-r13 -mfixed-range=F10-f15,f32-f127 -funwind-tabl=
es -falign-functions2 -mb-step -mconstant-gp  -c -o init/main.o init/main.c
Reading specs from /opt/ia64/lib/gcc-lib/ia64-cygnus-linux/2.96-ia64-000717=
/specs
gcc version 2.96-ia64-000717 snap 001117
 /opt/ia64/lib/gcc-lib/ia64-cygnus-linux/2.96-ia64-000717/cpp -lang-c -v -I=
/build/kaos/2.4.0-kdb-ia64/include -D__GNUC__=3D2 -D__GNUC_MINOR__=96 -D__G=
NUC_PATCHLEVEL__=3D0 -D__ia64 -D__ia64__ -D__linux -D__linux__ -D_LONGLONG =
-Dlinux -Dunix -D__LP64__ -D__ELF__ -D__ia64 -D__ia64__ -D__linux -D__linux=
__ -D_LONGLONG -D__linux__ -D__unix__ -D__LP64__ -D__ELF__ -D__linux -D__un=
ix -Asystem(linux) -Acpu(ia64) -Amachine(ia64) -D__OPTIMIZE__ -Wall -Wstric=
t-prototypes -D__LONG_MAX__=9223372036854775807L -D__KERNEL__ init/main.c |
 /opt/ia64/lib/gcc-lib/ia64-cygnus-linux/2.96-ia64-000717/cc1 -quiet -dumpb=
ase main.c -mfixed-range=F10-f15,f32-f127 -mb-step -mconstant-gp -O2 -Wall =
-Wstrict-prototypes -version -fno-strict-aliasing -fomit-frame-pointer -ffi=
xed-r13 -funwind-tables -falign-functions2 -o - |
 as -x -mconstant-gp -o init/main.o -
GNU CPP version 2.96-ia64-000717 snap 001117 (cpplib)
 (IA-64)
ignoring nonexistent directory "/opt/ia64/ia64-cygnus-linux/include"
#include "..." search starts here:
#include <...> search starts here:
 /build/kaos/2.4.0-kdb-ia64/include
 /opt/ia64/lib/gcc-lib/ia64-cygnus-linux/2.96-ia64-000717/include
 /opt/ia64/ia64-cygnus-linux/sys-include
End of search list.
GNU C version 2.96-ia64-000717 snap 001117 (ia64-cygnus-linux) compiled by =
GNU C version 2.95.2 20000220 (Debian GNU/Linux).
as: unrecognized option `-x'
init/main.c:207: output pipe has been closed
ia64-cygnus-linux-gcc: Internal compiler error: program cpp got fatal signa=
l 13


