From: Jes Sorensen <jes@sgi.com>
Date: Mon, 04 Sep 2006 08:55:54 +0000
Subject: Re: NODE_DATA without CONFIG_NUMA
Message-Id: <44FBEA1A.3020007@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060904062323.GA9293@verge.net.au>
In-Reply-To: <20060904062323.GA9293@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Horms wrote:
> On Mon, Sep 04, 2006 at 10:05:30AM +0200, Jes Sorensen wrote:
>> IMHO nodedata.h should provide alternative macros for non NUMA builds.
>> It seems silly to protect the include with #ifdef.
> 
> That is pretty much what I was thinking.
> But perhaps there is a reason for it.

My guess is the reason is lack of testing of all obscure configurations
:) That said, #ifdef'ing out a kernel include like that is almost always
wrong.

Cheers,
Jes



-- 
VGER BF report: U 0.500033
