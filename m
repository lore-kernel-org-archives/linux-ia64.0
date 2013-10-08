From: Ralf Baechle <ralf@linux-mips.org>
Date: Tue, 08 Oct 2013 07:00:54 +0000
Subject: Re: [PATCH v2 14/14] Kconfig cleanup (PARPORT_PC dependencies)
Message-Id: <20131008070054.GE1615@linux-mips.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1381209030-351-1-git-send-email-msalter@redhat.com>
 <1381209030-351-15-git-send-email-msalter@redhat.com>
In-Reply-To: <1381209030-351-15-git-send-email-msalter@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Tue, Oct 08, 2013 at 01:10:30AM -0400, Mark Salter wrote:

> Remove messy dependencies from PARPORT_PC by having it depend on one
> Kconfig symbol (ARCH_MAY_HAVE_PC_PARPORT) and having architectures
> which need it, select ARCH_MAY_HAVE_PC_PARPORT in arch/*/Kconfig.
> New architectures are unlikely to need PARPORT_PC, so this avoids
> having an ever growing list of architectures to exclude. Those
> architectures which do select ARCH_MAY_HAVE_PC_PARPORT in this
> patch are the ones which have an asm/parport.h (or use the generic
> version).

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
