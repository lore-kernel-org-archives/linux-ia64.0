From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 10 Jan 2002 19:24:52 +0000
Subject: Re: [Linux-ia64] have some trouble with cross compile (386->ia64)
Message-Id: <marc-linux-ia64-105590698805793@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805787@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805787@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>In file included from config/ia64/unwind-ia64.c:35:
>unwind.h:170:20: stdlib.h: No such file or directory

You didn't specify headers for the target.

You need to copy /usr/include and /usr/lib from the target IA-64 machine
onto the host IA-32 machine, and then use the configure options
	--with-headers=<...path to IA-64 headers...>
	--with-libs=<...path to IA-64 libs...>

Jim

