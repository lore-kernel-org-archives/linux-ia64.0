From: Jes Sorensen <jes@sunsite.dk>
Date: Mon, 10 Sep 2001 09:26:08 +0000
Subject: Re: [Linux-ia64] Location of hard coded IA32 libraries
Message-Id: <marc-linux-ia64-105590698805150@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805123@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805123@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Don" = Don Dugger <n0ano@valinux.com> writes:

Don> That's a pretty stong argument for not using the environment
Don> variable approach.  If we go with using a hard coded path, like
Don> `/usr/ia32', then there is no security hole.  This just becomes
Don> another tree that has to have protected files the same way `/'
Don> needs protected files.

I don't see the problem for environment variables either, LD_IA32_PATH
should just be treated like LD_LIBRARY_PATH and do magic for suid
binaries. On the other hand if the sysadmin allows you to overwrite
/usr/ia32/lib then you are in the same situation as if the user can
overwrite /usr/lib ;-)

Cheers
Jes

