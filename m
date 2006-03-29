From: James Bottomley <James.Bottomley@SteelEye.com>
Date: Wed, 29 Mar 2006 20:57:03 +0000
Subject: Re: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on
Message-Id: <1143665823.3248.46.camel@mulgrave.il.steeleye.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2006-03-29 at 12:51 -0800, Grant Grundler wrote:
> (4) James Bottomley couldn't boot his ZX2000 (HP ZX1 chipset) from git
> yesterday either.
> He had to update firmware to 2.31 version because of some changes
> in 2.6.16 SAL usage exposed an older SAL bug. Alex Williamson had
> dug up the details and I'm blanking on them right now.
> But his zx2000 is still not able to boot.
> 
> Could be multiple, unrelated problems being reported now.

No, I can confirm that reverting

[IA64] MCA Recovery: kernel context recovery table

fixes my boot problems.

I actually got slightly further than Jes with the analysis.  The problem
occurs because something in this changeset makes code that dynamically
loads the TLS libraries segfault.  If you look, Jes, you'll find init is
continually segfaulting and respawning.

James


