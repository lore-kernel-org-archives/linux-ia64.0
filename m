From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 29 Jun 2005 20:31:25 +0000
Subject: Re: problem booting -mm2 kernel on rx2600
Message-Id: <200506291431.25888.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506291236.14024.bjorn.helgaas@hp.com>
In-Reply-To: <200506291236.14024.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 29 June 2005 1:53 pm, Luck, Tony wrote:
> >To clarify, that's my GIT tree that isn't booting ... not Linus' tree.
> >My tree also has a bunch of patches that I pulled in from the ia64
> >mailing list.  I'm closing in on the problem patch using the
> >"git-rev-list --bisect" method.
> 
> The binary search hit bottom on this http://tinyurl.com/ds425 changeset.
> So it's unrelated to the problems that Stephane has with -mm tree.
> 
> Bjorn, Mark: any ideas why this is breaking zx2000?

No.  Current upstream + the patch you mention boots fine for me no
zx2000, both with "console=ttyS0" and with no "console=" argument
at all.

How does it fail for you?
