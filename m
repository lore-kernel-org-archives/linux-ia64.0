From: Joe Griffin <jjg@mscsoftware.com>
Date: Thu, 17 Oct 2002 14:47:04 +0000
Subject: Re: [Linux-ia64] system.h / pal.h / types.h
Message-Id: <marc-linux-ia64-105590709805183@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805181@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805181@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andreas,

I am making a few RPMS from source.  The
source has an include of asm/system.h.
If "asm/system.h" is in a "c" program
I do not think a person should have an error.

Are you saying that programs should
not have asm/system.h in them?

Joe

Andreas Schwab wrote:

>Joe Griffin <jjg@mscsoftware.com> writes:
>
>|> Hello,
>|> 
>|> The following program fails on my IA64 (tiger)
>|> with the 2.4.18 kernel and 2.2.4 glibc.  There
>|> is an error when system.h includes pal.h:
>|> 
>|> #include <stdio.h>
>|> #include <asm/system.h>
>|> main ()
>|> {
>|> printf("Hello World \n");
>|> }
>
>What are you trying to do?  Kernel headers are just that, kernel headers,
>and not for use in user programs.
>
>Andreas.
>
>  
>



