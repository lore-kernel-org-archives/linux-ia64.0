From: Peter Hurley <peter@hurleysoftware.com>
Date: Fri, 05 Sep 2014 16:17:16 +0000
Subject: Re: bit fields && data tearing
Message-Id: <5409E20C.3050004@hurleysoftware.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <54079B70.4050200@hurleysoftware.com> <1409785893.30640.118.camel@pasglop> <21512.10628.412205.873477@gargle.gargle.HOWL> <20140904090952.GW17454@tucnak.redhat.com> <540859EC.5000407@hurleysoftware.com> <20140904175044.4697aee4@alan.etchedpixels.co.uk> <5408C0AB.6050801@hurleysoftware.com> <20140905001751.GL5001@linux.vnet.ibm.com> <1409883098.5078.14.camel@jarvis.lan> <5409243C.4080704@hurleysoftware.com> <20140905040645.GO5001@linux.vnet.ibm.com> <063D6719AE5E284EB5DD2968C1650D6D17487F66@AcuExch.aculab.com> <5409AD0A.5090305@hurleysoftware.com> <063D6719AE5E284EB5DD2968C1650D6D17488265@AcuExch.aculab.com>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17488265@AcuExch.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>, "'paulmck@linux.vnet.ibm.com'" <paulmck@linux.vnet.ibm.com>
Cc: Jakub Jelinek <jakub@redhat.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Mikael Pettersson <mikpelinux@gmail.com>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Tony Luck <tony.luck@intel.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Miroslav Franc <mfranc@redhat.com>, Richard Henderson <rth@twiddle.net>, "linux-arm@vger.kernel.org" <linux-arm@vger.kernel.org>

On 09/05/2014 08:37 AM, David Laight wrote:
> From: Peter Hurley
>> On 09/05/2014 04:30 AM, David Laight wrote:
>>> I've seen gcc generate 32bit accesses for 16bit structure members on arm.
>>> It does this because of the more limited range of the offsets for the 16bit access.
>>> OTOH I don't know if it ever did this for writes - so it may be moot.
>>
>> Can you recall the particulars, like what ARM config or what code?
>>
>> I tried an overly-simple test to see if gcc would bump up to the word load for
>> the 12-bit offset mode, but it stuck with register offset rather than immediate
>> offset. [I used the compiler options for allmodconfig and a 4.8 cross-compiler.]
>>
>> Maybe the test doesn't generate enough register pressure on the compiler?
> 
> Dunno, I would have been using a much older version of the compiler.
> It is possible that it doesn't do it any more.
> It might only have done it for loads.
> 
> The compiler used to use misaligned 32bit loads for structure
> members on large 4n+2 byte boundaries as well.
> I'm pretty sure it doesn't do that either.
> 
> There have been a lot of compiler versions since I was compiling
> anything for arm.

Yeah, it seems gcc for ARM no longer uses the larger operand size as a
substitute for 12-bit immediate offset addressing mode, even for reads.

While this test:

struct x {
	short b[12];
};

short load_b(struct x *p) {
	return p->b[8];
}

generates the 8-bit immediate offset form,

short load_b(struct x *p) {
   0:	e1d001f0 	ldrsh	r0, [r0, #16]
   4:	e12fff1e 	bx	lr


pushing the offset out past 256:

struct x {
	long unused[64];
	short b[12];
};

short load_b(struct x *p) {
	return p->b[8];
}

generates the register offset addressing mode instead of 12-bit immediate:

short load_b(struct x *p) {
   0:	e3a03e11 	mov	r3, #272	; 0x110
   4:	e19000f3 	ldrsh	r0, [r0, r3]
   8:	e12fff1e 	bx	lr

Regards,
Peter Hurley

[Note: I compiled without the frame pointer to simplify the code generation]
