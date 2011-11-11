From: Paul Mundt <lethal@linux-sh.org>
Date: Fri, 11 Nov 2011 02:02:20 +0000
Subject: Re: [PATCH 4/5] treewide: Convert uses of ATTRIB_NORETURN to __noreturn
Message-Id: <20111111020220.GA29807@linux-sh.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1320917551.git.joe@perches.com> <abb1d8b542872ef3bfd695e85d3b8a0fd70645b9.1320917558.git.joe@perches.com>
In-Reply-To: <abb1d8b542872ef3bfd695e85d3b8a0fd70645b9.1320917558.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@google.com>, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf Baechle <ralf@linux-mips.org>, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Chris Metcalf <cmetcalf@tilera.com>, linux-ia64@vger.kernel.org, linux-m68k@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org

On Thu, Nov 10, 2011 at 01:41:45AM -0800, Joe Perches wrote:
> Use the more commonly used __noreturn instead of ATTRIB_NORETURN.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  arch/ia64/kernel/machine_kexec.c       |    2 +-
>  arch/m68k/amiga/config.c               |    2 +-
>  arch/mips/include/asm/ptrace.h         |    2 +-
>  arch/mips/kernel/traps.c               |    2 +-
>  arch/mn10300/include/asm/exceptions.h  |    2 +-
>  arch/powerpc/kernel/machine_kexec_32.c |    2 +-
>  arch/powerpc/kernel/machine_kexec_64.c |    2 +-
>  arch/s390/include/asm/processor.h      |    2 +-
>  arch/sh/kernel/process_32.c            |    2 +-
>  arch/sh/kernel/process_64.c            |    2 +-
>  arch/tile/kernel/machine_kexec.c       |    2 +-
>  include/linux/kernel.h                 |    6 +++---
>  12 files changed, 14 insertions(+), 14 deletions(-)
> 
For the SH bits:

Signed-off-by: Paul Mundt <lethal@linux-sh.org>
