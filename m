From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 13 Jun 2001 00:14:31 +0000
Subject: Re: [Linux-ia64] gcc issue ?
Message-Id: <marc-linux-ia64-105590693005723@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005722@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005722@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>cval = va_arg(args, char);

This isn't valid ISO C.  You must use promoted types when calling va_args,
and hence you must use int here, just like the error message says.

Older versions of gcc, and many other compilers tend to accept this, with
various results, e.g. sometimes it works, sometimes it doesn't.  New versions
of gcc always give an error at compile time.

>Following program fails compilation on linux ia64 os, but works on 
>other os's.

This isn't IA-64 specific behaviour.  If you use a new gcc, it will give this
same error on all systems.

Jim

