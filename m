From: Jim Wilson <wilson@tuliptree.org>
Date: Thu, 08 May 2003 17:24:04 +0000
Subject: Re: [Linux-ia64] Building IA-64 toolchain
Message-Id: <marc-linux-ia64-105590723705694@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705654@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705654@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2003-05-08 at 04:21, navin wrote:
> ../../gcc-3.2/gcc/config/ia64/fde-glibc.c:42:3: #error You need GLIBC 
> 2.2.4 or later on IA-64 Linux

The glibc copy you are using is too old.  This glibc will work with gcc
2.96 (sic), but it won't work with gcc 3.  There were related changes
made to glibc and gcc to enable unwind info to work correctly, which was
needed for C++ exception handling support.  Thus you can't use a new gcc
with an old glibc or vice versa.

David Mosberger mentioned testdrive.hp.com or something like that. 
Perhaps you could get an account there, and then get a newer copy of the
glibc header files from there.

Jim



