From: Uros Prestor <uros@turbolinux.com>
Date: Tue, 08 Aug 2000 22:43:37 +0000
Subject: Re: [Linux-ia64] Where are sources?
Message-Id: <marc-linux-ia64-105590678205287@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205286@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205286@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Daniel Schepler wrote:

> The Cygnus toolchain 2.9-ia64-000216-final from
> ftp.cygnus.com/private/intel.  It has a gcc/version.c dated May 1, and
> seems to be out of date since it won't accept -mconstant-gp.

You need extra patches for -mconstant-gp.  Your best bet is to get a
gnupro SRPM from our ftp site, unpack the SRPM and build from there.

> No glibc-2.1.3 distribution (except embedded in SRPM's).

Glibc 2.1 sources are not available externally AFAIK.  The good thing is
that 2.1 didn't change much recently.  Again, SRPM is your only option.

Uros

--
Uros Prestor
uros@turbolinux.com




