From: Gerrit Huizenga <gerrit@sequent.com>
Date: Wed, 26 Jul 2000 19:13:10 +0000
Subject: [Linux-ia64] RTC config option doesn't work for IA64 ?
Message-Id: <marc-linux-ia64-105590678205233@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is it just me, or does the RTC config option not generate a
working kernel for the IA64 test4 kernel + david's 0714 patches?

It appears that at least a header file is missing, I don't know
what goes in it as yet:  asm-ia64/mc146818rtc.h

Basically compilation fails if the config option is turned on.

gerrit


