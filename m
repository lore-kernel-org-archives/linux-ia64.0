From: Prarit Bhargava <prarit@sgi.com>
Date: Wed, 18 May 2005 13:57:13 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver
Message-Id: <428B49B9.7000803@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505131003.18143@bilbo.math.uni-mannheim.de>
In-Reply-To: <200505131003.18143@bilbo.math.uni-mannheim.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Rolf Eike Beer wrote:
> Prarit Bhargava wrote:
> 
>>Greg KH wrote:
>>
>>>On Tue, May 17, 2005 at 11:41:01AM -0400, Prarit Bhargava wrote:
>>>

>>Okay -- I'll go with Eike's suggestion above.  D_B_S + 1 number.
> 
> 
> D_B_S alone should be a unique identifier, so please don't use anything more 
> if you don't need it to make the slot name unique.
> 

On Altix, since the system can be cabled in a number of ways a pointer to the 
rack ID is definately useful and helps to uniquely identify the slot.  I'm going 
to use a 2 digit rack id, followed by the DDDD:BB:SS value.

P.

