From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 22 May 2007 09:26:13 +0000
Subject: Re: Where to get HP NUE to compile Open64 on IA32?
Message-Id: <20070522092613.GE26773@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070522034129.212450@gmx.net>
In-Reply-To: <20070522034129.212450@gmx.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

On Tue, May 22, 2007 at 05:41:29AM +0200, ultrasparc@gmx.de wrote:
> 
> I want to compile Open64 or ORC 2.1 on IA32. I need HP NUE for that. The HP NUE environment is no longer downloadable from the HP website. I already tried to compile Open64 v0.14, Open64 v0.15, Open64 v3.1 and ORC v2.1 on a Red Hat compatible Linux, but it always fails because HP NUE is missing.
>  
Are you trying to compile ORC/Open64 on a non native IA-64 machine?
I am not sure I understand why those compilers would have a dependency on NUE especially nowadays.


> Can somebody please provide me with a link to download HP NUE?

NUE is not maintained anymore.

> Is there a workaround to compile one of the mentioned compilers without HP NUE?

Don't know.

> Is there an alternative to HP NUE?
> 
Yes: use a native IA-64 machine.


-- 
-Stephane
