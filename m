From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 31 Aug 2000 20:08:07 +0000
Subject: Re: [Linux-ia64] new toolchain snapshots
Message-Id: <marc-linux-ia64-105590678205432@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205422@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205422@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	I'm getting a lot of warnings for format %p with the new toolchain on
	kernel 2.4.0-test7, e.g.

Before everyone goes and changes a lot of code, you should be aware that these
warnings have since changed several times in the FSF gcc sources.  And will
likely change again in the future.

The current FSF gcc sources won't give a warning for void * or char * used
with %p, and will accept other pointer types if you aren't using -pedantic.

We can either live with the current set of warnings, or I can try to bring over
patches from more recent FSF gcc sources to make them go away.

Jim

