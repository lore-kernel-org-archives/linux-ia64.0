From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 22 Jul 2003 01:38:10 +0000
Subject: Re: [PATCH] (2.4.21-bjorn-bk) Minimalist PAL mapping for SN2
Message-Id: <marc-linux-ia64-105883803301804@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105832171829546@msgid-missing>
In-Reply-To: <marc-linux-ia64-105832171829546@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 18 July 2003 7:05 pm, Christopher Wedgwood wrote:
> On Fri, Jul 18, 2003 at 10:13:02AM -0600, Bjorn Helgaas wrote:
> 
> > But I do prefer the machine vector approach, and there are several
> > other machine vectors used only at boot-time, so I don't think
> > that's an issue.
> 
> I've done this but must say it feels like excessive abstraction and an
> overkill approach.

Take a look at some existing machine vector implemetations
(platform_setup, platform_cpu_init, etc).  You should be
able to place the code to eliminate the #ifdefs, i.e., by
putting the SGI pal_map stuff in a file that's already
SGI-specific.

Bjorn

