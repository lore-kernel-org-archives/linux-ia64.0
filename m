From: CH Gowri Kumar <gkumar@csa.iisc.ernet.in>
Date: Tue, 27 May 2003 18:59:42 +0000
Subject: Re: [Linux-ia64] run time code generation for IA-64
Message-Id: <marc-linux-ia64-105590723706047@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706033@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706033@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,
> Where do you have R4 and R5 before using them?  
Did you mean to say that I have to save R4 and R5 before using them?

>Using local (stacked)
>registers instead might be a better choice here.
This is what exactly I came up with finally and it seems to be working 
fine for now. 

Just wondering why isn't there a standard calling convention on IA-64. 
Something of this sort(if at all to be saved):
	rp has to be saved in loc0
	sp has to be saved in loc1
	gp has to be saved in loc2

(Or I didn't read the manuals properly?)

Regards,
Gowri Kumar




