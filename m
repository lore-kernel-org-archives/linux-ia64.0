From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 27 Sep 2004 23:03:45 +0000
Subject: Re: INIT dumps broken?
Message-Id: <6487.1096326225@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
In-Reply-To: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 27 Sep 2004 22:34:15 +0900, 
Takao Indoh <indou.takao@soft.fujitsu.com> wrote:
>On Thu, 16 Sep 2004 00:14:11 +1000, Keith Owens wrote:
>>Agreed that MINSTATE_PHYS is broken.  Not sure that tpa is reliable
>>during INIT/MCA, especially as one of the possible causes of an MCA is
>>an invalid tlb.
>>
>>Can anybody describe why cpu 0 changed from 0xe... to 0xa... for the
>>idle task between 2.6.7-rc3 and 2.6.8?
>
>MINSTATE_END_SAVE_MIN_PHYS is also wrong?
>
>#define MINSTATE_END_SAVE_MIN_PHYS
>        or r12=r12,r14;         /* make sp a kernel virtual address */
>        or r13=r13,r14;         /* make `current' a kernel virtual address */
>        ;;
>
>In the case of swapper on cpu0, it calculates wrong address.
>If address of swapper on cpu0 is a000000100634000, this macro
>sets r13 to e000000100634000.

Fixed in Tony's bk tree since September 16.

