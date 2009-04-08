From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 08 Apr 2009 09:50:08 +0000
Subject: Re: cross-compilers
Message-Id: <87myara2zz.fsf@basil.nowhere.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090408003921.GA5054@ldl.fc.hp.com>
	<20090408010331.GB10768@sgi.com> <20090408054612.GA6744@ldl.fc.hp.com>
In-Reply-To: <20090408054612.GA6744@ldl.fc.hp.com> (Alex Chiang's message of "Tue, 7 Apr 2009 23:46:12 -0600")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Alex Chiang <achiang@hp.com> writes:

> * Robin Holt <holt@sgi.com>:
>> Don't know if this answers your problem, but I use the tools from
>> emdebian and they do not suffer from the problems you list below.
>
> Wow, this seems _much_ simpler. Once you get the toolchain
> installed, all you have to do is set ARCH and CROSS_COMPILE
> appropriately?
>
> I guess the question remains for Andrew. Since I pretty much did
> all the work needed to update his cross-compiler repo, is there
> still value in it?
>
> Or shall we just recommend emdebian to everyone? :)

SUSE also has cross-gcc-* rpms. Typically for icecream, but they're
relatively easy to extract into native format.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
