From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Mon, 23 Jul 2001 11:44:52 +0000
Subject: [Linux-ia64] __ia64_syscall ?
Message-Id: <marc-linux-ia64-105590693005861@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

this is probably a stupid question, but I'd spend ours
trying to solve it myself:

The reiserfs Tools 3.x.0j package from namesys.com
defines a Reiser-specific system call with sycall2_().

Linking of the package's programs fails because the
symbol __ia64_syscall is undefined. Examination
of glibc shows that __ia64_syscall is indeed not a global symbol.

This is on RedHat 7.1 (Seawolf).

How do I link such a program?

Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




