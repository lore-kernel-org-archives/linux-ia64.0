From: Alex Buell <alex.buell@munted.org.uk>
Date: Wed, 08 Apr 2009 11:08:36 +0000
Subject: Re: cross-compilers
Message-Id: <20090408120836.45d8b326@lithium.local.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090408003921.GA5054@ldl.fc.hp.com>
In-Reply-To: <20090408003921.GA5054@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Tue, 7 Apr 2009 18:39:21 -0600, I waved a wand and this message
magically appears in front of Alex Chiang:

> I've been using your cross-compilers here:
> 
> 	http://userweb.kernel.org/~akpm/cross-compilers/
> 
> for a long time now, but they're starting to suffer from a bit of
> neglect.

Why bother? 

You can use 'crossdev' to build your own cross-compilers instead. They
can build either stable or unstable toolchains for your target
architectures. 
-- 
http://www.munted.org.uk

Fearsome grindings.
