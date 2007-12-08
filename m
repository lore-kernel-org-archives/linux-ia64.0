From: Roland McGrath <roland@redhat.com>
Date: Sat, 08 Dec 2007 01:15:22 +0000
Subject: Re: [PATCH 2/3] Synchronize kernel RSE to user-space and back
Message-Id: <20071208011522.C3D3526F8EA@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1196959920.6586.8.camel@elijah.suse.cz>
In-Reply-To: <1196959920.6586.8.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> +  extern void ia64_ptrace_stop(void);
> +
> +  #define arch_ptrace_stop		ia64_ptrace_stop

My version of the macro takes arguments, in case some arch ever cares about
the details of the stop.  I saw no reason to remove them.  So:

#define arch_ptrace_stop(code, info)	ia64_ptrace_stop()

> +  #define arch_ptrace_stop_needed()	1

This should be:

#define arch_ptrace_stop_needed()	(!test_thread_flag(TIF_RESTORE_RSE))

It is worthwhile to avoid dropping the siglock when it's not necessary,
e.g. on subsequent signal stops after a previous stop.


Thanks,
Roland
