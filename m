From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Tue, 27 Feb 2001 01:04:01 +0000
Subject: Re: [Linux-ia64] Compiling 2.4.2
Message-Id: <marc-linux-ia64-105590693005212@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005211@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005211@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
> 
> I am trying to build an IA-64 kernel on a Lion B3 system running SuSE 7.1 beta.
> 
> Attached is the error log.  Any ideas on what is going on??
> 
> Regards,
> 

As far as I know, the IA-64 kernel is only up to 2.4.1. 

The IA-64 code that you find in the generic 2.4.2 kernel does not contain
the latest bits for IA-64.

To compile an IA-64 linux kernel in general you have to do:
	- grab the official linux kernel tarball 
	- go to http://www.kernel.org/pub/linux/ports/ia64 and grab the
	  corresponding IA-64 specific patch.
	- apply the IA-64 patch on top of the generic kernel.

So as as today, you need 2.4.1 and the latest patch for IA-64 is dated
010131.


-- 

-Stephane

