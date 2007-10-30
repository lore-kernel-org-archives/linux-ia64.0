From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Tue, 30 Oct 2007 09:24:21 +0000
Subject: Re: [IA64] Effective __clear_bit_unlock V2
Message-Id: <4726F845.6080806@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0710191050520.31589@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710191050520.31589@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> On Mon, 29 Oct 2007, Luck, Tony wrote:
> 
> 
>>Is this the final take on this ...  or was there a newer better faster cleaner
>>version?
> 
> 
> AFAICT this is final.
> 

Can you please explain:
- why should we have both acquisition and release semantics for
  __clear_bit(), while none of them is present for __set_bit() ?

- why should we have both acquisition and release semantics for
  __clear_bit() used for purposes other than clear_bit_unlock() ?

Thanks,

Zoltan

