From: Bill Nottingham <notting@redhat.com>
Date: Wed, 06 Dec 2000 15:24:49 +0000
Subject: [Linux-ia64] Re: static gcc from toolchain: howto?
Message-Id: <marc-linux-ia64-105590678205797@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Francis Galiegue (fg@mandrakesoft.com) said: 
> I've been trying for two days now to compile a static gcc (and possibly other
> tools too) but failed. When I try and set LDFLAGS or LDFLAGS_FOR_TARGET to
> -static, I get lots of multiple to _nl_* stuff, hence only i18n stuff... And I
> cannot seem to get out of it, no matter how I try. There's no static-* target
> either.
> 
> What is the solution? Or is there a static toolchain binary tree to be d/led
> somewhere?

configure --disable-nls works for me.

Bill

