From: James Wilson <wilson@cygnus.com>
Date: Tue, 27 Jun 2000 22:44:17 +0000
Subject: Re: [Linux-ia64] Using f6-f11 floating-point registers
Message-Id: <marc-linux-ia64-105590678205182@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205181@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205181@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Richard Henderson checked in a compiler patch on June 13 that eliminated the
need for the compiler to allocate integer and FP values to different FP
registers.  So as far as I know, there is no longer any compiler problem
that should affect the kernel's use of FP registers.  This change will be in
the next toolchain release.

Jim


