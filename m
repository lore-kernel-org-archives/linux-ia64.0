From: Matthew Wilcox <willy@debian.org>
Date: Wed, 01 Oct 2003 01:19:36 +0000
Subject: Re: [PATCH] disable legacy floppy related ioctl32s
Message-Id: <marc-linux-ia64-106497119307754@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106495318021597@msgid-missing>
In-Reply-To: <marc-linux-ia64-106495318021597@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 30, 2003 at 05:01:31PM -0700, Arun Sharma wrote:
> Here's the new patch. It should probably go to LKML now.

>  config BLK_DEV_FD
>  	tristate "Normal floppy disk support"
> -	depends on !X86_PC9800
> +	depends on ISA || M68K || SPARC64

Your tree is out of date.  Latest 2.6 has:
        depends on !X86_PC9800 && !ARCH_S390

I'm not sure that ISA is a great symbol to depend on for this.
"It works, but only by coincidence", IMO.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
