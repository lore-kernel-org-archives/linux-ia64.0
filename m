From: Jeff Woods <kazrak+kernel@cesmail.net>
Date: Wed, 10 Sep 2003 06:19:33 +0000
Subject: Re: IA32 execution layer
Message-Id: <marc-linux-ia64-106317491916322@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106316528210365@msgid-missing>
In-Reply-To: <marc-linux-ia64-106316528210365@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Matt Domsch wrote:
>>>Hi all, It seems that an IA32 execution layer is going to make its way=20
>>>onto upcoming ia64 windows systems. Is anyone thinking adding support=20
>>>for such a layer to linux-ia64?
>
>Popular I/T press is touting some new work by Intel to emulate x86=20
>instructions on IPF, which (per the articles) is faster than running it on=
=20
>the x86 hardware in the IPF.  I've gotten this query internally too.

Intel made some press releases in April 2003 about something they were=20
calling "BTRANS" which is designed to replace/enhance the IA32 hardware on =

Itanium processors by emulating some of the IA32 instructions in=20
software.  It is supposed to run faster than the "300MHz Pentium Pro"=20
effectively in the McKinley processors plus be able to execute instructions=
=20
(SSE, etc.) that the embedded IA32 hardware doesn't support.

At LinuxWorld/SF last month I cornered techs from Intel, Red Hat and SuSE=20
specifically to ask about BTRANS.  I discovered that it's now called "IA-32=
=20
Execution Layer" and the story from both Intel and SuSE was that it's being=
=20
incorporated into the "next release" of major Linux distributions for IA64 =

(e.g., SLES 8.1 or 9.0).  The Red Hat guy said something about it "isn't=20
open source" so they weren't planning to include it.  After relating Red=20
Hat's comments to the Intel folks, they simply said they would see that the=
=20
appropriate folks at Intel talk to Red Hat about it.

http://www.intel.com/pressroom/archive/releases/20030630comp.htm
[or: http://tinyurl.com/mtxw ]
>>In addition, later this year Intel plans to introduce [...] the IA-32=20
>>Execution Layer, a software technology that will enhance the performance =

>>of 32-bit applications running on the Itanium processor family-based=20
>>platforms. Prior to the IA-32 Execution Layer release, Microsoft will=20
>>offer a preview of the technology to end users who participate in the=20
>>Windows Server 2003 Service Pack 1 beta program.

http://www.intel.com/ebusiness/pdf/prod/itanium/dp_qrg.pdf
[or: http://tinyurl.com/mtyy ]
>>IA-32 Application Support: Today, like all Itanium 2 processors, Itanium =

>>2 processor 1.40 GHz with 1.5M L3 cache and Low Voltage Itanium 2=20
>>processor offer support for IA-32 applications. To further enhance this=20
>>capability Intel will soon introduce a new technology called IA-32=20
>>Execution Layer.=86=86

>>=86=86 Intel and Microsoft plan to introduce the IA-32 Execution Layer wi=
th=20
>>Windows Server 2003 Service Pack 1

http://www.intel.com/ebusiness/pdf/prod/itanium/ds022001.pdf
[or: http://tinyurl.com/mtz1 ]
>>IA-32 Application Support: Today, all Itanium 2 processors offer support =

>>for IA-32 applications; a new technology called IA-32 Execution Layer=20
>>will further enhance this capability in 2H =9203.

Of course, maximum performance requires native execution.  Compiling=20
performance-critical code with an optimizing native compiler is the proper =

solution.

--
Jeff Woods <kazrak+kernel@cesmail.net>=20


