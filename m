From: "Carlos O'Donell" <carlos@baldric.uwo.ca>
Date: Mon, 22 Dec 2003 09:08:40 +0000
Subject: Request to add IA32 syscall 270 (tgkill)
Message-Id: <marc-linux-ia64-107208457911976@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


linux-ia64,

Running 2.6.0 from linux-ia64-2.5 bk tree,

"IA32 syscall #270 issued, maybe we should implement it"

Would anyone be kind enough to add tgkill (#270) to the IA32 
syscall emulation? sys_tgkill looks safe enough (3 int parameters)
that it doesn't need a 32-bit wrapper?

Many thanks,
*Goes back to testing signal code*

Cheers,
Carlos.

