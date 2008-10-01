From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 01 Oct 2008 21:43:26 +0000
Subject: RE: [patch 2/4] ia64 use trace hook
Message-Id: <57C9024A16AD2D4C97DC78E552063EA352D48ADD@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080917082022.191956457@sli10-desk.sh.intel.com>
In-Reply-To: <20080917082022.191956457@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is one warning from the compiler:

arch/ia64/kernel/ptrace.c:1243: warning: ignoring return value of 'tracehook_report_syscall_entry', declared with attribute warn_unused_result

Caused by this part of patch 2:

Index: linux/arch/ia64/kernel/ptrace.c
...
@@ -1260,9 +1239,8 @@ syscall_trace_enter (long arg0, long arg
                     long arg4, long arg5, long arg6, long arg7,
                     struct pt_regs regs)
...
+       if (test_thread_flag(TIF_SYSCALL_TRACE))
+               tracehook_report_syscall_entry(&regs);

But apart from that it all seems OK.

How do I tell whether it is all working?  Roland's wiki
that you pointed to in patch 0/4 doesn't have any testing
tips (and seems to have some old information ... it talks
about CONFIG_UTRACE being available after HAVE_ARCH_TRACEHOOK
is enabled ... but grep says there are no UTRACE references in
the kernel).

-Tony
