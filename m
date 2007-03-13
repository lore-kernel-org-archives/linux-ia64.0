From: Prarit Bhargava <prarit@redhat.com>
Date: Tue, 13 Mar 2007 00:02:26 +0000
Subject: Re: NULL pointer in ia64/irq_chip-mask/unmask function (V3)
Message-Id: <45F5EA12.7050503@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200703072138.l27LcRVE022938@agluck-lia64.sc.intel.com>
In-Reply-To: <200703072138.l27LcRVE022938@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



Jay Lan wrote:
> Eric W. Biederman wrote:
>   
>> "Luck, Tony" <tony.luck@intel.com> writes:
>>
>>     
>>> This patch now has an extra piece for the SGI specific
>>> occurance of the same context (as noted by Eric).  Just
>>> posting here in case I misunderstood, or mis-typed while
>>> applying. Now supplying no-op functions for SN usage.
>>>       
>> Looks ok to me.
>>     
>
> This version (V3) fixed my problem on SN. :)
>
>   

Also fixes the problem on HP rx2620/rx2660 ...

P.
>   
