From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 07 Jan 2005 17:51:17 +0000
Subject: Re: INIT handler modification
Message-Id: <1105120277.25267.29.camel@eeyore>
List-Id: <linux-ia64.vger.kernel.org>
References: <41DE990B.702@Ext.Bull.Net>
In-Reply-To: <41DE990B.702@Ext.Bull.Net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2005-01-07 at 15:13 +0100, Francois Wellenreiter wrote:
> Here is the main point, the present code of INIT handler for slave CPUs 
> is reduced
> to (file arch/ia64/kernel/mca_asm.S) :
> ______________________________
> 
> GLOBAL_ENTRY(ia64_slave_init_handler)
> 1:      br.sptk 1b
> END(ia64_slave_init_handler)
> ______________________________
> 
> I think that when the kernel is deadlocked on another CPU than the 
> monarch one,
> the traces may be a bit short when I push on the "DUMP" button to have a 
> complete
> diagnosis of my system.

You're right, this is a serious problem that needs to be fixed.
Unfortunately, it's a little more complicated than the change
you propose, because we need per-CPU areas (or locking) for
saving the min-state areas from firmware.  I think the recent
"per cpu MCA/INIT" changes are heading in this direction, so
please take a look at those, try them out, and improve them!

