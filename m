From: Jiri Slaby <jslaby@suse.cz>
Date: Fri, 16 Sep 2011 21:20:36 +0000
Subject: Re: ia64 build broken on CONFIG_DEBUG_STACK_USAGE
Message-Id: <4E73BDA4.1050007@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <4E5204E3.7070107@suse.cz>
In-Reply-To: <4E5204E3.7070107@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: 
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Linux kernel mailing list <linux-kernel@vger.kernel.org>

On 08/22/2011 09:27 AM, Jiri Slaby wrote:
> Hi,
>=20
> when CONFIG_DEBUG_STACK_USAGE is selected, I get these errors:
>   CC      arch/ia64/kernel/asm-offsets.s
> In file included from arch/ia64/kernel/asm-offsets.c:9:
> include/linux/sched.h: In function =91stack_not_used=92:
> include/linux/sched.h:2419: error: =91IA64_TASK_SIZE=92 undeclared (first
> use in this function)
> include/linux/sched.h:2419: error: (Each undeclared identifier is
> reported only once
> include/linux/sched.h:2419: error: for each function it appears in.)
> include/linux/sched.h:2419: error: =91IA64_THREAD_INFO_SIZE=92 undeclared
> (first use in this function)
> make[1]: *** [arch/ia64/kernel/asm-offsets.s] Error 1
> make: *** [prepare0] Error 2

Hi again. This is still an issue in the current Linus tree.

Do you have any idea how to fix it?

thanks,
--=20
js
suse labs
