From: Matthew Wilcox <willy@debian.org>
Date: Wed, 19 Nov 2003 20:35:51 +0000
Subject: Re: [PATCH] remove unimplemented syscalls noise
Message-Id: <marc-linux-ia64-106927465604938@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106926030617023@msgid-missing>
In-Reply-To: <marc-linux-ia64-106926030617023@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 19, 2003 at 12:33:17PM -0800, David Mosberger wrote:
>   Matthew> Every time we emit something to the system log, it's a
>   Matthew> potential support call.  Our friends in other parts of HP
>   Matthew> are already unhappy with how much output Linux produces
>   Matthew> even when everything's OK.  It's also a sysadmin hassle as
>   Matthew> logfiles fill up more quickly when this kind of junk goes
>   Matthew> by.
> 
> Can I say dmesg -n4??

No, you can't.  Users check their logfiles.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
