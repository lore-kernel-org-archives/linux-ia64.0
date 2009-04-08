From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 08 Apr 2009 05:54:57 +0000
Subject: Re: cross-compilers
Message-Id: <20090407225457.86f8a458.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090408003921.GA5054@ldl.fc.hp.com>
	<20090408010331.GB10768@sgi.com>
	<20090408054612.GA6744@ldl.fc.hp.com>
In-Reply-To: <20090408054612.GA6744@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>
Cc: Robin Holt <holt@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Tue, 7 Apr 2009 23:46:12 -0600 Alex Chiang <achiang@hp.com> wrote:

> * Robin Holt <holt@sgi.com>:
> > Don't know if this answers your problem, but I use the tools from
> > emdebian and they do not suffer from the problems you list below.
> 
> Wow, this seems _much_ simpler. Once you get the toolchain
> installed, all you have to do is set ARCH and CROSS_COMPILE
> appropriately?
> 
> I guess the question remains for Andrew. Since I pretty much did
> all the work needed to update his cross-compiler repo, is there
> still value in it?

We would benefit very much from having someone who actually maintains a
suite of cross-compilers for kernel developers.

Yes, the stuff I put together is very old and at the time crosstool was
horridly hard to use.  Hardly any combinations of anything actually
worked - what you see there is about 5% of the toolchains I had to
build.  Apparently is has become better.

> Or shall we just recommend emdebian to everyone? :)

That sounds suspiciously like "thou shalt use debian".  I was so
traumatised by dselect ten years ago that I don't think I could afford
the therapy bills.

