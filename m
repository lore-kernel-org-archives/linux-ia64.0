From: "David S. Miller" <davem@redhat.com>
Date: Wed, 24 Apr 2002 23:53:31 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905517@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Jesse Barnes <jbarnes@sgi.com>
   Date: Wed, 24 Apr 2002 16:13:08 -0700
   
   So the penalty for using DAC comes down to ~.0375% for a 64k I/O, and
   the benefit is that you don't have to use 32 bit mappings (which can
   be scarce on some platforms).

No some, _your_ platform.   It is the only one with this problem.

You only need this 4GB memory for consistent memory, not
for anything else!  %99 of the kernel is going to use memory
for pages and data, not descriptors.

You can use zones and whatnot to make sure this isn't a problem at
all.

