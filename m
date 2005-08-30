From: Greg Edwards <edwardsg@sgi.com>
Date: Tue, 30 Aug 2005 20:56:16 +0000
Subject: Re: execute sn2 early console setup only on sn2s
Message-Id: <20050830205615.GA10207@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050830203446.GA7680@sgi.com>
In-Reply-To: <20050830203446.GA7680@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 30, 2005 at 10:45:18PM +0200, Andreas Schwab wrote:
| Greg Edwards <edwardsg@sgi.com> writes:
| 
| > Index: git-linus/arch/ia64/kernel/setup.c
| > =================================| > --- git-linus.orig/arch/ia64/kernel/setup.c	2005-08-30 15:13:11.399460142 -0500
| > +++ git-linus/arch/ia64/kernel/setup.c	2005-08-30 15:15:53.959188707 -0500
| > @@ -288,7 +288,7 @@ early_console_setup (char *cmdline)
| >  	int earlycons = 0;
| >  
| >  #ifdef CONFIG_SERIAL_SGI_L1_CONSOLE
| > -	{
| > +	if (ia64_platform_is("sn2")) {
| >  		extern int sn_serial_console_early_setup(void);
| >  		if (!sn_serial_console_early_setup())
| >  			earlycons++;
| 
| The first thing sn_serial_console_early_setup does is to check for sn2.

Ugg.  Completely forget this.  I was getting this confused with a
different SuSE tree.  ;)

Greg
