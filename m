From: "Lynch, Rusty" <rusty.lynch@intel.com>
Date: Tue, 24 May 2005 16:20:08 +0000
Subject: RE: [patch 1/4] Kprobes support for IA64
Message-Id: <032EB457B9DBC540BFB1B7B519C78B0E07340747@orsmsx404.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523154228.049327000@csdlinux-2.jf.intel.com>
In-Reply-To: <20050523154228.049327000@csdlinux-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@sgi.com>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>
Cc: akpm@osdl.org, "Luck, Tony" <tony.luck@intel.com>, "Seth, Rohit" <rohit.seth@intel.com>, prasanna@in.ibm.com, ananth@in.ibm.com, systemtap@sources.redhat.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>From: Keith Owens [mailto:kaos@sgi.com]
>Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com> wrote:
>>
>>This patch adds the kdebug die notification mechanism needed by
Kprobes.
>> 	      case 0: /* unknown error (used by GCC for
__builtin_abort()) */
>>+		if (notify_die(DIE_BREAK, "kprobe", regs, break_num,
>TRAP_BRKPT, SIGTRAP)
>>+			       	= NOTIFY_STOP) {
>>+			return;
>>+		}
>> 		die_if_kernel("bugcheck!", regs, break_num);
>> 		sig = SIGILL; code = ILL_ILLOPC;
>> 		break;
>
>Nit pick.  Any break instruction in a B slot will set break_num 0, so
>you cannot tell if the break was inserted by kprobe or by another
>debugger.  Setting the string to "kprobe" is misleading here, change it
>to "break 0".

Good catch.  We'll update the informational string.

    --rusty
