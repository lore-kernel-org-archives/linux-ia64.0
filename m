From: Keith Owens <kaos@sgi.com>
Date: Thu, 11 Mar 2004 08:14:13 +0000
Subject: Re: 2.6.3 Heisenbug in unwind.c
Message-Id: <6960.1078992853@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2654.1077624337@ocs3.ocs.com.au>
In-Reply-To: <2654.1077624337@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 10 Mar 2004 23:56:03 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Wed, 10 Mar 2004 16:27:07 +1100, Keith Owens <kaos@sgi.com> said:
>  Keith> 00015a00 00015a70 005ced40
>  Keith> 00015a80 00015b20 005ced58
>  Keith> 00015ac0 00015d10 005c6828 Illegal insert, belongs to __init text
>How nasty!
>
>I don't see this problem with:
>
>	gcc version 3.3.3 20040125
>	ld version 2.14.90.0.7 20031029 Debian GNU/Linux
>
>I doubt it's a gcc bug.  Can you try with a more recent version
>of binutils?

The bug only manifests itself when one particular SGI patch is applied
to the kernel.  When one particular object from that patch is linked
into the kernel then it trips the unwind glitch.  My problem is that
the code looks fine, and so does the unwind data in its object.  Still
digging, valid C code should not be able to do this to ld :(.

