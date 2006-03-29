From: Jes Sorensen <jes@sgi.com>
Date: Wed, 29 Mar 2006 18:04:35 +0000
Subject: Re: gate.S and recent toolchains
Message-Id: <442ACC33.4050402@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB0DE.1040409@sgi.com>
In-Reply-To: <442AB0DE.1040409@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:
> Chen, Kenneth W wrote:
>> Russ Anderson wrote on Wednesday, March 29, 2006 9:23 AM
>>> Chen, Kenneth W wrote:
>>>> Russ, do you reference __mca_table at run time?  It looks like so.  It's
>>>> problematic that __mca_table is in __init section.  Though I doubt that
>>>> was the reason Jes ran into.
>>> It was right next to __ex_table in the original patch.
>>> Yes, it is referenced at run time and should not be in 
>>> the __init section.
>> I guess it's a merge error then :-P
> 
> This patch moves __mca_table out of the __init section.
> 
> Jes, can you give this a try?

I am 99.999% sure it wont make a difference. I even tried reverting your
full patch and just adding the two lines to asmmacros.h and I still hit
the failture.

Cheers,
Jes

