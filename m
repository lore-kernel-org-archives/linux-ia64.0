From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 25 Jun 2003 21:06:48 +0000
Subject: Re: IA-32 support patch: fcntl64 calls are broken
Message-Id: <marc-linux-ia64-105657534422322@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105649509512709@msgid-missing>
In-Reply-To: <marc-linux-ia64-105649509512709@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 24 June 2003 4:51 pm, Arun Sharma wrote:
> Currently, sys32_fcntl64() is broken, because it passes F_*64 commands to sys_fcntl(), which it doesn't understand. The F_XXX64 commands need to be converted to F_XXX before calling sys_fcntl().

As far as I can tell, this is almost equivalent to, but uglier than,
the mips64 version:

	sys32_fcntl64(unsigned int fd, unsigned int cmd, unsigned long arg)
	{
	        switch (cmd) {
	        case F_GETLK64:
	                return sys_fcntl(fd, F_GETLK, arg);
	        case F_SETLK64:
	                return sys_fcntl(fd, F_SETLK, arg);
	        case F_SETLKW64:
	                return sys_fcntl(fd, F_SETLKW, arg);
	        }

	        return sys32_fcntl(fd, cmd, arg);
	}

parisc, ppc64, s390, and sparc64 have this, which I think is
also equivalent, but uglier:

	asmlinkage long sys32_fcntl64(unsigned int fd, unsigned int cmd, unsigned long arg)
	{
	        if (cmd >= F_GETLK64 && cmd <= F_SETLKW64)
	                return sys_fcntl(fd, cmd + F_GETLK - F_GETLK64, arg);
	        return sys32_fcntl(fd, cmd, arg);
	}

I'd like to see the ia64 version be similar to the mips64 version.
The remaining difference is the int/long argument; maybe you
can resolve that too...

Bjorn

