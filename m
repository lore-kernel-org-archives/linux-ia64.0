From: Sam Ravnborg <sam@ravnborg.org>
Date: Sat, 25 Jan 2003 20:19:57 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.59)
Message-Id: <marc-linux-ia64-105590709805752@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jan 24, 2003 at 09:02:32PM -0800, David Mosberger wrote:
> diff -Nru a/Makefile b/Makefile
> --- a/Makefile	Fri Jan 24 20:41:05 2003
> +++ b/Makefile	Fri Jan 24 20:41:05 2003
> @@ -170,7 +170,7 @@
>  NOSTDINC_FLAGS  = -nostdinc -iwithprefix include
>  
>  CPPFLAGS	:= -D__KERNEL__ -Iinclude
> -CFLAGS 		:= $(CPPFLAGS) -Wall -Wstrict-prototypes -Wno-trigraphs -O2 \
> +CFLAGS 		:= $(CPPFLAGS) -Wall -Wstrict-prototypes -Wno-trigraphs -g -O2 \

Hi David.

I do not think "-g" was included on purpose...

	Sam

