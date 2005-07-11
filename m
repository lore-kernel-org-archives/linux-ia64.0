From: david mosberger <dmosberger@gmail.com>
Date: Mon, 11 Jul 2005 19:21:55 +0000
Subject: Re: [PATCH 2.6.13-rc1 07/10] IOCHK interface for I/O error handling/detecting
Message-Id: <ed5aea4305071112212756924@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB6961.2060508@jp.fujitsu.com>
In-Reply-To: <42CB6961.2060508@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yeah, PAL calls are very expensive.  On a zx1-type machine, I/O reads
take on the order of 1,000 cycles, so a PAL call would be an order of
magnitude more expensive.  Is PAL_MC_FLUSH really needed in that case?

  --david

On 7/11/05, Luck, Tony <tony.luck@intel.com> wrote:
> 
> >Why not be extra safe and call PAL_MC_FLUSH?  Or would that be too
> >expensive?
> 
> Just timed a call to PAL_MC_DRAIN (which is what I assume you meant).
> 
> Just over 13,000 cycles.
> 
> Is that too expensive?  How long does an i/o read take from a typical device?
> 
> -Tony
>
