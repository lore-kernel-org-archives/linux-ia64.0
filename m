From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 10 Nov 2000 22:47:25 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels test10 and upper?
Message-Id: <marc-linux-ia64-105590678205683@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am maintaining a stable compiler for the ia64-linux (formerly Trillian)
group.  You can get it via ftp from ftp.cygnus.com in pub/ia64-linux.
This compiler assumes that you are using glibc 2.2.  This is based on FSF
gcc snapshots from the July/August timeframe.  There are patches to make
uit mostly work with glibc 2.1.3.

You can try using FSF gcc snapshots, but they tend to be a bit chaotic.
Especially so for ia64, because we are still doing optimization work on the
ia64 port, and hence we are occasionally destabilizing the ia64 port with
new optimizations.

Jim

