From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 19 Mar 2004 01:15:16 +0000
Subject: Re: [PATCH] ia64/Kconfig
Message-Id: <200403181715.16448.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403151717.39545.bjorn.helgaas@hp.com>
In-Reply-To: <200403151717.39545.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 18 March 2004 5:07 pm, Kenneth Chen wrote:
> >  choice
> > +	prompt "Processor type"
> > +	default ITANIUM
> > +
> 
> Anyone still running itanium processor nowadays? :-)

Yeah baby!  In fact, I'm writing this mail on a Bug^WBig Sur box right
now.  :)  A dual 733 MHz Merced isn't half bad as a desktop, though
it's a bit loud.

[jbarnes@spamtin jbarnes]$ uname -a
Linux spamtin 2.6.2 #1 SMP Wed Feb 4 13:19:37 PST 2004 ia64 GNU/Linux
[jbarnes@spamtin jbarnes]$ cat /proc/cpuinfo
processor  : 0
vendor     : GenuineIntel
arch       : IA-64
family     : Itanium
model      : 0
revision   : 6
archrev    : 0
features   : standard
cpu number : 0
cpu regs   : 4
cpu MHz    : 733.337968
itc MHz    : 733.337968
BogoMIPS   : 731.90

processor  : 1
vendor     : GenuineIntel
arch       : IA-64
family     : Itanium
model      : 0
revision   : 6
archrev    : 0
features   : standard
cpu number : 0
cpu regs   : 4
cpu MHz    : 733.337968
itc MHz    : 733.337968
BogoMIPS   : 729.80

Jesse the masochist

