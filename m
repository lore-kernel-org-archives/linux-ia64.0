From: Alex Chiang <achiang@hp.com>
Date: Wed, 08 Apr 2009 05:46:12 +0000
Subject: Re: cross-compilers
Message-Id: <20090408054612.GA6744@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090408003921.GA5054@ldl.fc.hp.com> <20090408010331.GB10768@sgi.com>
In-Reply-To: <20090408010331.GB10768@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

* Robin Holt <holt@sgi.com>:
> Don't know if this answers your problem, but I use the tools from
> emdebian and they do not suffer from the problems you list below.

Wow, this seems _much_ simpler. Once you get the toolchain
installed, all you have to do is set ARCH and CROSS_COMPILE
appropriately?

I guess the question remains for Andrew. Since I pretty much did
all the work needed to update his cross-compiler repo, is there
still value in it?

Or shall we just recommend emdebian to everyone? :)

Thanks.

/ac

