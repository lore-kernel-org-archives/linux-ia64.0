From: Keith Owens <kaos@ocs.com.au>
Date: Sun, 02 Dec 2001 06:12:27 +0000
Subject: Re: [Linux-ia64] No include/asm-ia64/mmzone.h in 2.4.16-ia64-011128
Message-Id: <marc-linux-ia64-105590698805572@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 1 Dec 2001 23:27:14 -0600, 
John Hesterberg <jh@sgi.com> wrote:
>On Sun, Dec 02, 2001 at 03:23:01PM +1100, Keith Owens wrote:
>> I tried compiling 2.4.16-ia64-011128 as type SGI-SN1.  It broke at
>> include/linux/mmzone.h:138 trying to include asm/mmzone.h which does
>> not exist on ia64.  Is ia64-011128 supposed to compile sn1/sn2 out of
>> the box or are there extra patches required?
>
>No, as you've discovered, it's missing mmzone.h.

Is that intentional or a mistake?  I have converted ia64 to kbuild 2.5,
ready to send the patch to Linus.  But I could only test platform DIG,
all of the other platforms (HP_SIM, SGI_SN1, SGI_SN2, GENERIC) got
compile errors, even under kbuild 2.4.

I don't have time to fix up the platform code.  Unless somebody can
supply patches against ia64-011128 to make all the platforms compile, I
will have to hope that the conversion for the failing platforms is
correct.  OTOH, they don't work now, so why worry ;).


