From: Richard Hirst <rhirst@linuxcare.com>
Date: Thu, 14 Mar 2002 01:11:07 +0000
Subject: Re: [Linux-ia64] gcc/binutils bug building parted?
Message-Id: <marc-linux-ia64-105590701905269@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905246@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905246@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 13, 2002 at 10:34:53AM -0800, David Mosberger wrote:
> Oh, I see now what's wrong: data4 implicitly aligns the data to a 4-byte
> boundary.  To get an unaligned entry, you'd have to use data4.ua or gcc
> would have to emit the data byte by byte (data1).
> 
> This needs to be fixed in the compiler.  Would you mind filing a bug
> report with the gcc folks?

Will do.

> typedef unsigned char guid_t[16];
> #define EFI_GUID(a,b,c,b0,b1,b2,b3,b4,b5,b6,b7)

OK, thanks.  I'll work up a patch for parted to do that if no-one beats
me to it.

Cheers,
  Richard


