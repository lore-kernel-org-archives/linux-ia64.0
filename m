From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 14 Dec 2000 21:16:32 +0000
Subject: Re: [Linux-ia64] gdb on ia64
Message-Id: <marc-linux-ia64-105590678205847@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205835@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205835@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Can any one explain why gdb on ia64 tries to attach (and gets an error) to
>a process that died with a sigsegv
>even when I start it with the --core option, giving it a core dump.

You can't "attach" to a process that has died.  I assume you are just trying
to look at the code dump.  This works on all of the systems I have.

>I am using TurboLinux IA-64 Beta 2, with  egcs-core-20001002  and
>egcs-g++-20001002.

You might try asking on the TurboLinux mailing list.  I am not very familiar
with TurboLinux releases, and don't have any machines running it right now.

Jim

