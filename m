From: Mario Smarduch <cms063@email.mot.com>
Date: Fri, 11 Apr 2003 18:48:24 +0000
Subject: Re: [Linux-ia64] gdb problem unwinding abort in signal
Message-Id: <marc-linux-ia64-105590723705470@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705468@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705468@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

> >>>>> On Fri, 11 Apr 2003 13:17:38 -0500, Mario Smarduch <cms063@email.mot.com> said:
>
>   Mario> When our application aborts in the signal handler (no
>   Mario> altstack is setup) the stack backtrace discontinues at the
>   Mario> signal handler.
>
>   Mario> (gdb) where #0 0x20000000000a6342 in kill () at soinit.c:56
>   Mario> #1 0x20000000000a61f0 in raise (sig=6) at
>   Mario> ../sysdeps/posix/raise.c:27 #2 0x20000000000a8a70 in abort ()
>   Mario> at ../sysdeps/generic/abort.c:88 #3 0x4000000000000910 in
>   Mario> sig_report_and_die ()
>
>   Mario> Manually unwinding the stack shows the rp set to
>   Mario> ia64_sigtramp(). The privilaged gate page simplifies allot of
>   Mario> things, but it poses a problem to our software because we
>   Mario> send events for all signals of importance, and count on the
>   Mario> core dump to capture the full call trace prior to and
>   Mario> including the signal - gdb displays this full backtrace on
>   Mario> all other architectures we run on.
>
>   Mario> If this is the problem how does one get around it besides
>   Mario> manually unwinding the stack?
>
> There is a gdb patch in the works that will use libunwind for
> backtracing purposes.  Unwinding across signal handlers will work just
> fine then (at least with reasonably recent kernels).  An old
> (alpha-quality) snapshot of such a gdb is at:
>
>         ftp://ftp.hpl.hp.com/pub/linux-ia64/ugdb-ia64-020531.tar.gz
>
> and someone from Red Hat is now working on updating the gdb patch for
> libunwind v0.9 (and hopefully on getting it into the official gdb
> tree).
>
>         --david

Great we'll try it, currently we're running  debian
distro 2.4.20-cgl-1.1-mckinley-smp.

thks,
    Mario.



