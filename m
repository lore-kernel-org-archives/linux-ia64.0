From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 29 Mar 2001 19:08:50 +0000
Subject: Re: [Linux-ia64] relocation truncated to fit: PCREL21B __rtti_class
Message-Id: <marc-linux-ia64-105590693005369@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005368@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005368@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>iaxxsusr.o:/data/d022301/iaxxqeryif.hpp:175: relocation truncated to fit:
>PCREL21B __rtti_class

This is probably an out-of-range branch/call.  These are supposed to be
handled automatically by the toolchain, but currently, they work only if
you explicitly turn on linker relaxation.  You can do that with the gcc
option "-Wl,-relax".

If that doesn't solve the problem, then I would need more info.  Preferably
a testcase that I can use to reproduce the problem here.

Jim


