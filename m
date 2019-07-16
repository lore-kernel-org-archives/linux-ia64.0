From: Sven Schnelle <svens@stackframe.org>
Date: Tue, 16 Jul 2019 18:53:10 +0000
Subject: Re: [PATCH 1/2] arch: mark syscall number 435 reserved for clone3
Message-Id: <20190716185310.GA12537@t470p.stackframe.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190714192205.27190-1-christian@brauner.io>
 <20190714192205.27190-2-christian@brauner.io>
 <e14eb2f9-43cb-0b9d-dec4-b7e7dcd62091@de.ibm.com>
 <20190716130631.tohj4ub54md25dys@brauner.io>
In-Reply-To: <20190716130631.tohj4ub54md25dys@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christian Brauner <christian@brauner.io>
Cc: linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, arnd@arndb.de, linux-sh@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org, Christian Borntraeger <borntraeger@de.ibm.com>, linux-m68k@lists.linux-m68k.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Vasily Gorbik <gor@linux.ibm.com>

Hi,

[Adding Helge to CC list]

On Tue, Jul 16, 2019 at 03:06:33PM +0200, Christian Brauner wrote:
> On Mon, Jul 15, 2019 at 03:56:04PM +0200, Christian Borntraeger wrote:
> > I think Vasily already has a clone3 patch for s390x with 435. 
> 
> A quick follow-up on this. Helge and Michael have asked whether there
> are any tests for clone3. Yes, there will be and I try to have them
> ready by the end of the this or next week for review. In the meantime I
> hope the following minimalistic test program that just verifies very
> very basic functionality (It's not pretty.) will help you test:
> [..]

On PA-RISC this seems to work fine with Helge's patch to wire up the
clone3 syscall.

root@c3750:/# clonetest
Parent process received child's pid 84 as return value
Parent process received child's pidfd 3
Parent process received child's pid 84 as return argument
Child process with pid 84
root@c3750:/# echo $?
0

Regards
Sven
