From: "Pimenov, Sergei" <sergei.pimenov@intel.com>
Date: Sun, 12 Nov 2000 20:41:59 +0000
Subject: RE: [Linux-ia64] Recommended compiler for compiling kernels test1
Message-Id: <marc-linux-ia64-105590678205686@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jim,

Does this compiler support cross-compilation?

p.s.
 


-----Original Message-----
From: Jim Wilson [mailto:wilson@cygnus.com]
Sent: Saturday, November 11, 2000 1:47 AM
To: Francis Galiegue
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels test10 and upper? 


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

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


