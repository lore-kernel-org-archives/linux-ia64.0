From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 29 Nov 2001 00:41:15 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.16)
Message-Id: <marc-linux-ia64-105590698805559@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The ia64 patch for 2.4.16 has been updated (in the usual place).  The
patch fixes the NUMA issue reported by Andreas.  Also, there were a
couple of cleanups which should make it in theory possible to use this
source tree for building both x86 and ia64 kernels.  Thanks to John
Hesterberg for some of those patches.  I suspect this will make some
people happy and others unhappy (since it increases the patch size,
slightly).  But the additional changes required to the x86 specific
files are so small that it shouldn't be a major issue.

	--david

