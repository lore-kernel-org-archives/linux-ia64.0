From: Takao Indoh <indou.takao@soft.fujitsu.com>
Date: Mon, 27 Sep 2004 13:34:15 +0000
Subject: Re: INIT dumps broken?
Message-Id: <CEC4A496AE6233indou.takao@soft.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
In-Reply-To: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 16 Sep 2004 00:14:11 +1000, Keith Owens wrote:

>On Wed, 15 Sep 2004 00:56:15 -0700, 
>David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>>> On Wed, 15 Sep 2004 17:16:47 +1000, Keith Owens <kaos@sgi.com> said:
>>
>>  Keith> The use of 0xa.. for cpu 0 is causing an MCA when cpu 0
>>  Keith> receives INIT.
>>
>>The MINSTATE_PHYS-version of MINSTATE_GET_CURRENT() looks broken to
>>me.  Perhaps changing "dep reg=0,reg,61,3" to a "tpa" is all that's
>>needed there.  Can someone check this out?  I probably won't get to it
>>today and will be on vacation starting tomorrow.
>
>Agreed that MINSTATE_PHYS is broken.  Not sure that tpa is reliable
>during INIT/MCA, especially as one of the possible causes of an MCA is
>an invalid tlb.
>
>Can anybody describe why cpu 0 changed from 0xe... to 0xa... for the
>idle task between 2.6.7-rc3 and 2.6.8?

MINSTATE_END_SAVE_MIN_PHYS is also wrong?

#define MINSTATE_END_SAVE_MIN_PHYS
        or r12=r12,r14;         /* make sp a kernel virtual address */
        or r13=r13,r14;         /* make `current' a kernel virtual address */
        ;;

In the case of swapper on cpu0, it calculates wrong address.
If address of swapper on cpu0 is a000000100634000, this macro
sets r13 to e000000100634000.


Regards,
Takao Indoh
