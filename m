From: Christian Hildner <christian.hildner@hob.de>
Date: Wed, 14 Dec 2005 12:02:33 +0000
Subject: Re: C++ Template instantiation problem
Message-Id: <43A009D9.3020309@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <GGEMIIODJPBLIOCGNLDJAEBBCAAA.kriti.dutta@oracle.com>
In-Reply-To: <GGEMIIODJPBLIOCGNLDJAEBBCAAA.kriti.dutta@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kriti,

gcc 2.96 is pretty old and had some bugs/limitations. You might try a 
current release instead.
If  the current gcc releases still shows the problem you may report the 
bug to the gcc mailing list.

Christian

Kriti Dutta schrieb:

> I am trying to compile some C++ code using the g++ version 2.96 in a Red
>Hat Linux ia64 box.
> And while compiling one of the file which has a lot of code for template
>instantiations I get the following error:
>	 __gp does not cover short data segment
> moreover compilation of this file takes about a day and then finally I get
>the above error.
> I have also tried fragmenting the code into different files even that did
>not work and I got some other kind of error:
> 	gnu.linkonce relocation truncated to fit: PCREL21B
>
> If anybody has ever encountered such errors may be he/she can help us with
>the workaround available.
>
>
>   Kriti.
>

