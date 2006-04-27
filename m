From: Jes Sorensen <jes@sgi.com>
Date: Thu, 27 Apr 2006 12:10:53 +0000
Subject: Re: [patch] update sn2 defconfig
Message-Id: <4450B4CD.4060203@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq07j5bs50k.fsf@jaguar.mkp.net>
In-Reply-To: <yq07j5bs50k.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote:
> On Thu, Apr 27, 2006 at 06:10:35AM -0400, Jes Sorensen wrote:
>> +CONFIG_NODES_SHIFT=8
> 
> Jack/Jes,
> 
> Shouldn't we have this at 10 so we get the most exposure possible.

I'd be fine with that, I just stuck with the default.

>> -# CONFIG_INFINIBAND_IPOIB_DEBUG is not set
>> +CONFIG_INFINIBAND_IPOIB_DEBUG=y
> 
> Why turn on debugging for everyone?

I didn't do anything there, It was the Infinibug stuff that turned it
on itself.

Cheers,
Jes
