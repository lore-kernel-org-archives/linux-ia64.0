From: "Tang, Yu" <yu.tang@intel.com>
Date: Thu, 25 Oct 2001 01:12:51 +0000
Subject: RE: [Linux-ia64] C union on ia-64
Message-Id: <marc-linux-ia64-105590698805389@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805377@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805377@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

/* size.c */
#include "stido.h"
int main(int argc, char *argv[])
{
	printf("%d,%d\n",sizeof(unsigned long),sizeof(void*));
	return 0;
}

under linux:
$gcc size.c -o size
$./size
8,8

under 64-bit WinXP:
c:\temp\size
4,8

-----Original Message-----
From: KOCHI, Takayoshi [mailto:t-kouchi@mvf.biglobe.ne.jp]
Sent: 2001=E5=B9=B410=E6oe^25=E6-=A5 3:50
To: linux-64
Subject: Re: [Linux-ia64] C union on ia-64


> PS: Interestingly enought, I believe Intel's slide is actually
> wrong.  If `ULONG' is an `unsigned long' and `PVOID' is a `void *'
> then all of the data items have the same size and the two structures
> can be used interchangably on either IA32 or IA64.  It's a
> dangerous technique but it would work in this case.

I believe win64 uses P64 for its programming model.
(while we use LP64 instead)
So their ULONG is still 32bit in IA64.

Regards,
--=20
KOCHI Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

