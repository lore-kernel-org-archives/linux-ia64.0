From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 09 Aug 2000 00:14:54 +0000
Subject: Re: [Linux-ia64] Where are sources?
Message-Id: <marc-linux-ia64-105590678205289@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205286@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205286@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	The Cygnus toolchain 2.9-ia64-000216-final from
	ftp.cygnus.com/private/intel.  It has a gcc/version.c dated May 1, and
	seems to be out of date since it won't accept -mconstant-gp.

We are working on a new toolchain release to replace this one.  This release
will be made in conjunction with the glibc-2.2 release, because of numerous
incompatible ABI changes.  Meanwhile, you might try an SRPM from one of the
other linux releases.

You will have to rebuild everything from scratch when the new toolchain/glibc
releases come out though.

Jim

