From: David Miller <davem@davemloft.net>
Date: Wed, 25 Mar 2009 02:04:14 +0000
Subject: Re: kernel unaligned accesses on 2.6.29.
Message-Id: <20090324.190414.59071734.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090324172856.GA8908@sgi.com>
	<20090325011418.GB8908@sgi.com>
In-Reply-To: <20090325011418.GB8908@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: holt@sgi.com
Cc: chuck.lever@oracle.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: Robin Holt <holt@sgi.com>
Date: Tue, 24 Mar 2009 20:14:18 -0500

> You either need to use memcpy, or not define it as an unsigned char.
> Tony, any suggestions?

memcpy() might not work in this scenerio.

GCC can still emit an inline 64-bit memory access if it
deems that the objects involved should be sufficiently
aligned.

It might not be able to in this specific case, but it is
something to be aware of.  Don't be convinced of any fix
for this until the assembler is inspected by hand :-)
