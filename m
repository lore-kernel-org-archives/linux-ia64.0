From: Theodore Tso <tytso@mit.edu>
Date: Tue, 18 Sep 2001 09:00:50 +0000
Subject: [Linux-ia64] Re: PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805202@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805199@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805199@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 18, 2001 at 10:34:50AM +0200, Andreas Jaeger wrote:
> 
>    * /lib: consistent scheme for all 32bit systems and x86-64,
>      sparc64, ppc64, zSeries (s390x).
> 
>    * iA64 today has a 32bit emulation mode, but 64bit is the
>      (only) favored one; Alpha is too long established. (64bit
>      libs will go to /lib)
> 

Does Sparc/Ultrasparc use /lib and /lib64?  Or will this be a change
for the Ultrasparc platform?

						- Ted

