From: Christian Hildner <christian.hildner@hob.de>
Date: Wed, 10 Dec 2003 11:02:23 +0000
Subject: Re: RT specifics features
Message-Id: <marc-linux-ia64-107105433724490@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107104745718077@msgid-missing>
In-Reply-To: <marc-linux-ia64-107104745718077@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ghislain K. schrieb:

>
>     Hi All,
>
>     I don't know if i write to the right mailing list for my 
> problems... but I need quick help. So :
>
>     1) Situation :
>          My lab. is benching a IA64 itanium2 quadi-processors platform 
> for our Real-Time applications.
>
>     2) What we were intent to do  :
>         We tried to patch a 2.4.18 from Red Hat Enterprise 2.1 with :
>          * Robert Love patch on cpu_affinity,
>          * Tim Hockins patch on procstate,
>         to isolate alone each ours processes on its CPU.
>
>     It doesn't work until now and the quadri must go out our labs the 
> 15 dec.
>
>     3) SOS :
>     So, I am looking for a "distribution", a tree, a patch, a clue, 
> ... to include such features in my kernel or an other. 

2.4.18 is pretty old for that features. You might try 2.4.21 + ia64 
patch from kernel.org.

Good luck

Christian

