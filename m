From: Keith Owens <kaos@sgi.com>
Date: Wed, 15 Sep 2004 14:14:11 +0000
Subject: Re: INIT dumps broken?
Message-Id: <9680.1095257651@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
In-Reply-To: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 15 Sep 2004 00:56:15 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Wed, 15 Sep 2004 17:16:47 +1000, Keith Owens <kaos@sgi.com> said:
>
>  Keith> The use of 0xa.. for cpu 0 is causing an MCA when cpu 0
>  Keith> receives INIT.
>
>The MINSTATE_PHYS-version of MINSTATE_GET_CURRENT() looks broken to
>me.  Perhaps changing "dep reg=0,reg,61,3" to a "tpa" is all that's
>needed there.  Can someone check this out?  I probably won't get to it
>today and will be on vacation starting tomorrow.

Agreed that MINSTATE_PHYS is broken.  Not sure that tpa is reliable
during INIT/MCA, especially as one of the possible causes of an MCA is
an invalid tlb.

Can anybody describe why cpu 0 changed from 0xe... to 0xa... for the
idle task between 2.6.7-rc3 and 2.6.8?

