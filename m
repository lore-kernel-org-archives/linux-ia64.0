From: "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp>
Date: Fri, 05 Apr 2002 03:44:43 +0000
Subject: Re: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)
Message-Id: <marc-linux-ia64-105590701905389@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905358@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905358@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 Hi Jack-san and David-san.

 Thank you for sending the patch.
 Yes, I will take care to do it.

At Thu, 4 Apr 2002 07:54:57 -0800,
David Mosberger wrote:
> 
> >>>>> On Thu, 04 Apr 2002 19:29:46 +0900, "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp> said:
> 
>   Hideki>  I have a favor to ask David.  If possible, plase give me
>   Hideki> the patch you had resolved this problem. I have been looking
>   Hideki> for the patch in all email(linux-ia64) but I could not find
>   Hideki> this patch.
> 
> Jack just sent the patch.  Caveat: it has not been tested much.  You
> may be better off reverting to the pre-August 2001 version of
> strncpy() if stability is what you want.
> 
> 	--david
> 

