From: Paul Bame <bame@fc.hp.com>
Date: Wed, 29 Jan 2003 17:48:51 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.59)
Message-Id: <marc-linux-ia64-105590709805770@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I had the same problem with mconf when I built with 2.96 (it just
> printed the name of the Kconfig file and exited with status 1,
> strace didn't show any unexpected system call failures).

I had the same experience with the new assembler and gcc 2.96
with scripts/conf used by 'make oldconfig'.  Traced it to
fopen(name,"r") returning 0 with errno=EINVAL. open(2) was never called
according to strace and 'name' was perfectly fine.  Smelled like a tool
chain problem so moved to Debian and it went away (gcc version 3.2.2
20030124 (Debian prerelease))

	-P

