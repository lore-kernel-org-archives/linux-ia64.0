From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 15 Nov 2008 01:38:28 +0000
Subject: RE: [PATCH] Ensure PSR.ac is cleared for early userspace
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35C3BDD44@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
In-Reply-To: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 GLOBAL_ENTRY(kernel_execve)
+       rum IA64_PSR_AC
        mov r15=__NR_execve                     // put syscall number in place
        break __BREAK_SYSCALL
        br.ret.sptk.many rp

I'm not overly happy with this because I still don't understand how
the PSR.ac bit became set in this context.  This patch papers
over the problem by clearing psr.ac ... but it shouldn't be
set at this point!

As far as I can see usage of psr.ac is as follows:

1) When Linux first boots the code in head.S transitions to
virtual mode ... this code sets PSR.ac=0.

2) Eight of the code paths in ivt.S set PSR.ac=1 before
transitioning to C code.  Thus interrupt handlers, page faults
and other traps are executed with .ac=1.  This is controlled by the
PSR_DEFAULT_BITS define ... which is (and I think always has)
been defined to set psr.ac.

[I'm a bit puzzled as to why we want strict alignment checking
in interrupt/fault handlers, but are satisfied with more relaxed
behaivour in base code]

I'm also puzzled why this issue only just surfaced, and why I
only see it on generic kernels.

The problem may be related to some interrupt behavior.  If I
tweak just the "__interrupt" code to not set psr.ac (but leave
the other seven fault handlers setting psr.ac=1) then I don't
see any unaligned traps in early init code.

-Tony
