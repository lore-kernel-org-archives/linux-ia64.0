From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 13 Dec 2000 21:09:18 +0000
Subject: Re: [Linux-ia64] binary kernel module build flags
Message-Id: <marc-linux-ia64-105590678205827@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205824@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205824@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

You shouldn't worry about A-step or B0-step processors unless you personally
are still using them because you haven't gotten upgrades yet.  I'd like to
eliminate the compiler -ma-step option before gcc3 comes out, which means it
won't be in the next compiler release.  Meanwhile, if you must use A-step or
B0-step processors, then you must use the -ma-step compiler option.  Otherwise,
I recommend using -mb-step for now, which will support B1 and higher processor
steppings.

The current round of OS releases are coming out with B step kernel support only
by default, and A step support is provided with an optional kernel (TurboLinux)
or not at all (Red Hat).

Jim

