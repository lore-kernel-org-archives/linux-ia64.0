From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 05 Feb 2002 21:21:50 +0000
Subject: Re: [Linux-ia64] IA64 Link Relocation operators
Message-Id: <marc-linux-ia64-105590698805993@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805983@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805983@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Could somebody tell me where i could find documentation on IA64 Link
>relocation operators.

The only formal documention I know about is in the Assembly Language
Reference Guide available from the Intel web site.  It has a chapter on
Link-relocation Operators.  The explanations are very short, and probably
not understandable unless you have a good understanding of how IA-64
compilers work.

There is also documentation of sorts in the GNU sources.  Gcc has code to
emit assembly using link-relocation operators, GNU as has code to create
relocation entries in object files, and GNU ld has code to evaluate the
relocation operators at link time.

Jim

