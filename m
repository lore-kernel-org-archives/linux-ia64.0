From: Matthew Wilcox <willy@debian.org>
Date: Mon, 31 May 2004 14:32:04 +0000
Subject: Re: IA64_GENERIC vs. NUMA/DISCONTIG/VIRTUAL_MEM_MAP
Message-Id: <20040531143204.GG5850@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040531044843.GA25705@dannf.org>
In-Reply-To: <20040531044843.GA25705@dannf.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, May 30, 2004 at 10:48:43PM -0600, dann frazier wrote:
> hey,
>   It was requested that I turn on DISCONTIGMEM in my builds for Debian, in order to support
> Altix boxes.  This option is not currently selectable w/ a 2.6.6 "Generic" kernel, but
> it is with all other flavors.
> 
>   I dug around to see if this is intentional, and found evidence[1] that it is not.
> >From what I can grok from Documentation/kbuild/kconfig-language.txt, select will force
> these options off - maybe "depends on" is what was intended?

No, select forces these options on.  It's like Enhances: versus Suggests:
(if Enhances actually worked, which it doesn't).  The reason you can't
turn DISCONTIGMEM on with a generic kernel is because it's forced on.  I
suspect the bug submitter was smoking something good.

> | config IA64_GENERIC
> | 	bool "generic"
> |+	select NUMA
> |+	select ACPI_NUMA
> |+	select VIRTUAL_MEM_MAP
> |+	select DISCONTIGMEM

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
