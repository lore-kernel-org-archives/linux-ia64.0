From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 07 May 2004 21:32:18 +0000
Subject: Re: [ia64 R&D] CONFIG_IA64_MCA
Message-Id: <200405071432.18116.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
In-Reply-To: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday, May 7, 2004 2:28 pm, Chen, Kenneth W wrote:
> Is there another patch or this is the latest one?
> http://www.gelato.unsw.edu.au/linux-ia64/0405/9514.html
>
> If that's the latest one, then it won't boot on any machine with nomca
> parameter because once match found, it stuck in the for loop and memcmp
> endlessly, cp never gets incremented :-(

Oh, oops.  Your patch looks simpler (and correct!) :)

Jesse
