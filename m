From: Takao Indoh <indou.takao@soft.fujitsu.com>
Date: Tue, 28 Sep 2004 00:03:59 +0000
Subject: Re: INIT dumps broken?
Message-Id: <CFC4A4EEA7C66Dindou.takao@soft.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
In-Reply-To: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 28 Sep 2004 09:03:45 +1000, Keith Owens wrote:

>>MINSTATE_END_SAVE_MIN_PHYS is also wrong?
>>
>>#define MINSTATE_END_SAVE_MIN_PHYS
>>        or r12=r12,r14;         /* make sp a kernel virtual address */
>>        or r13=r13,r14;         /* make `current' a kernel virtual address
>>  */
>>        ;;
>>
>>In the case of swapper on cpu0, it calculates wrong address.
>>If address of swapper on cpu0 is a000000100634000, this macro
>>sets r13 to e000000100634000.
>
>Fixed in Tony's bk tree since September 16.

I found a patch you had posted. Thanks.

Regards,
Takao Indoh
