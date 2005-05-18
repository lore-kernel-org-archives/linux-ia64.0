From: Prarit Bhargava <prarit@sgi.com>
Date: Wed, 18 May 2005 16:54:12 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver
Message-Id: <428B7334.4050807@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505131003.18143@bilbo.math.uni-mannheim.de>
In-Reply-To: <200505131003.18143@bilbo.math.uni-mannheim.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Prarit Bhargava wrote:
> Prarit Bhargava wrote:
> 
>> Prarit Bhargava wrote:
>>
>>>>
>>>> D_B_S alone should be a unique identifier, so please don't use 
>>>> anything more if you don't need it to make the slot name unique.
>>>>
>>>
>>> On Altix, since the system can be cabled in a number of ways a 
>>> pointer to the rack ID is definately useful and helps to uniquely 
>>> identify the slot.  I'm going to use a 2 digit rack id, followed by 
>>> the DDDD:BB:SS value.
>>>

NAK this.  I'm changing the name of the sysfs file.

Thanks,

P.
