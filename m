From: Jim Wilson <wilson@specifixinc.com>
Date: Sat, 13 Sep 2003 01:39:33 +0000
Subject: Re: shared library creation using -Bsymbolic
Message-Id: <marc-linux-ia64-106341718103782@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106340698329016@msgid-missing>
In-Reply-To: <marc-linux-ia64-106340698329016@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2003-09-12 at 15:45, Umut Aymakoglu wrote:
>    I have gcc3(3.0.4) installed on my machine with the ld(2.11.90.0.8). The
> following compile fails. Has anybody seen a similar thing?

This works with binutils-2.14, but fails with binutils-2.13.  I see the
same behaviour with both IA-32 and IPF.  So this is apparently a known
bug that has already been fixed.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com

