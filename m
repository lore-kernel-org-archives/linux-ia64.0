From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Wed, 15 Oct 2003 02:40:44 +0000
Subject: Re: GENERIC still failing?
Message-Id: <marc-linux-ia64-106618574212827@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106617635106445@msgid-missing>
In-Reply-To: <marc-linux-ia64-106617635106445@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 15 Oct 2003 12:15:48 +1000 Ian Wienand <ianw@gelato.unsw.edu.au> wrote:

| On Tue, Oct 14, 2003 at 05:22:05PM -0700, Jesse Barnes wrote:
| > Looks like CONFIG_NUMA and CONFIG_DISCONTIGMEM are missing from the
| > config being built.  A generic kernel won't work without them.
| 
| mea culpa, as usual. Is there some way to make it when you select
| generic it always requires CONFIG_NUMA/DISCONTIGMEM?

Yes, use "select" (see Documentation/kbuild/kconfig-language.txt).
E.g.,

config GENERIC
	bool "blah"
	select NUMA
	select DISCONTIGMEM
	---help---


| Also, trying to look at the help text, it seems that the sub-items of
| a 'choice' in Kconfig can't have individual help texts?
| 
| For example 
|  
| choice
| 	prompt "IA-64 processor type"
| 	---help---
| 	 this will show when you select help on 'IA-64 processor type'
| config ITANIUM
| 	bool "Itanium"
| 	---help---
| 	 this text appears not to show when you select help on 'Itanium' 
| 	 in the choice.
| endchoice
| 
| I'm not sure if this is the desired effect, but certainly some of the
| help texts appear mis-placed under an option of the choice rather than
| at the choice it's self (see attached for example).

--
~Randy
