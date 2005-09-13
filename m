From: Sam Ravnborg <sam@ravnborg.org>
Date: Tue, 13 Sep 2005 20:02:50 +0000
Subject: Re: ia64 circular dependency on asm-offsets.h
Message-Id: <20050913200250.GC18319@mars.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509131602.j8DG2Ffr005104@agluck-lia64.sc.intel.com>
In-Reply-To: <200509131602.j8DG2Ffr005104@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 13, 2005 at 09:02:15AM -0700, Luck, Tony wrote:
> I am not proud of this patch (but Linus has already declared that
> I have no taste :-).  More of a case of changing out one ugly hack for
> a new ugly hack.  It's only merit is that this ugly hack works, where
> the old one has run into terminal problems.

I have no better ideas than this one.

Matthew Wilcox once suggested a much more fundamental change.
See: http://www.gelato.unsw.edu.au/archives/linux-ia64/0211/4114.html

Absolutely not 2.6.14 material - just wanted to bring the idea back
again.

	Sam
