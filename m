From: "H . J . Lu" <hjl@valinux.com>
Date: Thu, 16 Nov 2000 17:16:51 +0000
Subject: Re: [Linux-ia64] gcc: thanks
Message-Id: <marc-linux-ia64-105590678205732@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205731@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205731@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 16, 2000 at 05:35:56PM +0100, Francis Galiegue wrote:
> Thanks to Jes Sorensen for enlightening me about the cause of the error, but
> thanks above all to H. J. Lu for his patch. It has worked wonderfully.
> 
> FWIW, I compiled the 001024 snapshot will all RCS patches up to .033 and it
> works like a charm. Now, on to glibc 2.2...
> 

I have 2 patches to fix an ABI bug in binutils and glibc where the
DT_INIT/FINI entries should be the function address, not the function
descriptor. As of today, binutils and glibc assume they are function
addresses. My patches are at

http://ftp.valinux.com/pub/support/hjl/ia64/bfd-init.patch
http://ftp.valinux.com/pub/support/hjl/ia64/glibc-2.2-init.patch

They should be tested and checked in ASAP.

Thanks.


-- 
H.J. Lu (hjl@valinux.com)

