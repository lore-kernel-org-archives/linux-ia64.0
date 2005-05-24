From: Keith Owens <kaos@sgi.com>
Date: Tue, 24 May 2005 05:40:40 +0000
Subject: Re: [patch 1/4] Kprobes support for IA64
Message-Id: <6261.1116913240@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Mon, 23 May 2005 08:39:07 MST."
             <20050523154228.049327000@csdlinux-2.jf.intel.com> 
References: <20050523154228.049327000@csdlinux-2.jf.intel.com>
In-Reply-To: <20050523154228.049327000@csdlinux-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
Cc: akpm@osdl.org, tony.luck@intel.com, rohit.seth@intel.com, rusty.lynch@intel.com, prasanna@in.ibm.com, ananth@in.ibm.com, systemtap@sources.redhat.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 23 May 2005 08:39:07 -0700, 
Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com> wrote:
>
>This patch adds the kdebug die notification mechanism needed by Kprobes.
> 	      case 0: /* unknown error (used by GCC for __builtin_abort()) */
>+		if (notify_die(DIE_BREAK, "kprobe", regs, break_num, TRAP_BRKPT, SIGTRAP)
>+			       	= NOTIFY_STOP) {
>+			return;
>+		}
> 		die_if_kernel("bugcheck!", regs, break_num);
> 		sig = SIGILL; code = ILL_ILLOPC;
> 		break;

Nit pick.  Any break instruction in a B slot will set break_num 0, so
you cannot tell if the break was inserted by kprobe or by another
debugger.  Setting the string to "kprobe" is misleading here, change it
to "break 0".

