From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Tue, 11 Mar 2003 16:20:56 +0000
Subject: Re: [Linux-ia64] running X with 2.4.18 kernel
Message-Id: <marc-linux-ia64-105590709806022@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905497@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905497@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 11 March 2003 7:45 am, Zac Morris wrote:
> I'n trying to run X with 2.4.18 kernel ...

That's a pretty old kernel!  The ia64 patch was released over a
year ago.  All else being equal, it will be much easier to help
you if you're running a more current kernel.  The 2.4.20 ia64
patch was released on 12/10/2002, and has no major known issues.

> I have read all the postings on this archive regarding
> this problem and tried running the chatr script (from
> ftp://ftp.hpl.hp.com/pub/linux-ia64/chatr-v0.0.tar.gz)
> that David had posted, I'm getting a whole lot of
> syntax errors. What could be the problem?

Did you compile chatr?  It compiles fine for me:

    09:15:43 lp:~$ socksify wget -q ftp://ftp.hpl.hp.com/pub/linux-ia64/chatr-v0.0.tar.gz
    09:15:59 lp:~$ tar -zxvf chatr-v0.0.tar.gz
    chatr.c
    09:16:02 lp:~$ cc chatr.c
    09:16:08 lp:~$ 

If you're having trouble compiling it, please include the actual
error messages you're seeing.

> Where can I get the release notes for the first 2.4.18
> patch that David made?

They're included in the diff file (linux-2.4.18-ia64-020226.gz).
Here they are:

        - better ia64 IRQ affinity support (Erich Focht)
        - include Firewire configuration for ia64 (Bdale Garbee/Grant Grundler)
        - fix ia32 GDT initialization (Don Dugger)
        - bump gcc3.x inlining threshold to 2000 to get things to
          compile with gcc3.1
        - don't make ia64 stack and data executable by default and
          drop lazy-execute bit support; restore original interface
          for page-fault handler
        - fix clone2() stack initialization bug found by Asit Mallick
        - implement ia32 emulation for SIOCGIFCONF (Don Dugger)
        - fix siginfo kernel data leaking
        - make page fault handler pass reason for a SIGSEGV/SIGILL in
          siginfo.si_isr (see include/asm-ia64/siginfo.h for details)
        - /proc/efivars update (Matt Domsch)
        - fix I/O SAPIC irq routing (makes ACPI power button events work)
          (J.I. Lee)
        - fix alternate TLB miss handlers to not lose Exception Deferral bit
        - MCA update (Jenna Hall)
        - update perfmon to v1.0 (Stephane Eranian)
        - add PTRACE_GETREGS/PTRACE_SETREGS (Yoav Zach)
        - fix handling of .label_state/.copy_state in kernel unwinder
        - fix exception handler to not assume that archdata_start is
          non-NULL for all modules (Bjorn Helgaas)
        - move initial kernel stack from region 4 down to region 3
        - don't define _HAVE_ARCH_IPV6_CSUM as we don't really have it
          (Bdale Garbee/Grant Grunderl)
        - drop .bias from ld4.bias instruction in spinlock code to avoid
          CPU errata (Asit Mallick)


