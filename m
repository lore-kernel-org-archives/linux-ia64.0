From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 14 Dec 2000 20:31:42 +0000
Subject: Re: [Linux-ia64] binary kernel module build flags
Message-Id: <marc-linux-ia64-105590678205846@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205824@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205824@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Please don't drop the A-stepping support too early! Most of our machines
>and half of our processors are still A3 step! And they probably won't be
>upgraded before February 2001.

If I remove the compiler -ma-step option now, it will be about 3-6 months
before you see it in an OS release.  I believe now is the right time
to drop support for it, as it doesn't make sense for next year's compiler
releases to contain A step processor support.  The current compiler release
will obviously continue to support A step, so this does not effect anyone who
is currently still using A step machines.

Jim

