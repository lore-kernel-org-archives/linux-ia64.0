From: Matthew Wilcox <willy@debian.org>
Date: Wed, 15 Oct 2003 11:24:30 +0000
Subject: Re: GENERIC still failing?
Message-Id: <marc-linux-ia64-106621720303447@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106617635106445@msgid-missing>
In-Reply-To: <marc-linux-ia64-106617635106445@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 15, 2003 at 12:15:48PM +1000, Ian Wienand wrote:
> Also, trying to look at the help text, it seems that the sub-items of
> a 'choice' in Kconfig can't have individual help texts?
> 
> For example 
>  
> choice
> 	prompt "IA-64 processor type"
> 	---help---
> 	 this will show when you select help on 'IA-64 processor type'
> config ITANIUM
> 	bool "Itanium"
> 	---help---
> 	 this text appears not to show when you select help on 'Itanium' 
> 	 in the choice.
> endchoice
> 
> I'm not sure if this is the desired effect, but certainly some of the
> help texts appear mis-placed under an option of the choice rather than
> at the choice it's self (see attached for example).

Which *config tool are you using?  make config/oldconfig/defconfig have
a bug which Roman hasn't got round to pushing upstream yet.

This whitespace-damaged diff shows what needs to be fixed:

Index: scripts//kconfig/conf.c
=================================RCS file: /var/cvs/linux-2.6/scripts/kconfig/conf.c,v
retrieving revision 1.3.2.1
retrieving revision 1.3
diff -u -p -r1.3.2.1 -r1.3
--- scripts//kconfig/conf.c     8 Oct 2003 20:38:32 -0000       1.3.2.1
+++ scripts//kconfig/conf.c     28 Sep 2003 04:06:34 -0000      1.3
@@ -175,7 +175,7 @@ int conf_string(struct menu *menu)
                        break;
                case '?':
                        /* print help */
-                       if (line[1] = 0) {
+                       if (line[1] = '\n') {
                                help = nohelp_text;
                                if (menu->sym->help)
                                        help = menu->sym->help;

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
