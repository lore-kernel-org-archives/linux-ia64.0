From: Ronald Veldema <veldema@cs.fau.de>
Date: Mon, 12 May 2003 13:32:52 +0000
Subject: Re: [Linux-ia64] as & .restore sp directive
Message-Id: <marc-linux-ia64-105590723705727@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705723@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705723@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I know, that is what gcc does as well.
It just looks inefficient to add extra jumps, esp. if we don't need them...
R.

CH Gowri Kumar wrote:

>>Adding two .prologue statements or two ".restore sp, 1"
>>won't work. Any ideas ?
>>    
>>
>How about doing it this way?
>if()
>{
>	....
>	goto RETURN;
>}
>else
>{
>	....
>	goto RETURN;
>}
>RETURN:
>	.restore sp 
>	mov r12 = r2
>	br.ret.sptk.many b0
>	.endp
>
>This way I feel you can put all the necessary things (restoring sp, 
>returning etc..) at one place, instead of duplicating the same code.
>
>Regards,
>Gowri Kumar
>
>  
>



