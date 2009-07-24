From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Fri, 24 Jul 2009 01:39:55 +0000
Subject: Re: [PATCH] ia64: minor Makefile simplification through use of	cc-ifversion
Message-Id: <87ws5yoo44.wl%peterc@nicta.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200907232056.51064.elendil@planet.nl>
	<20090723212809.GB9488@merkur.ravnborg.org>
In-Reply-To: <20090723212809.GB9488@merkur.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Frans Pop <elendil@planet.nl>, linux-ia64@vger.kernel.org, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> "Sam" = Sam Ravnborg <sam@ravnborg.org> writes:

Sam> On Thu, Jul 23, 2009 at 08:56:50PM +0200, Frans Pop wrote:

Sam> The above change is correct.  But I really wonder if the original
Sam> code was correct?  Do we really only want to use the -mtune
Sam> options for this specific gcc version?  If this is indeed the
Sam> case this deserves a comment explaning this.

I suspect it should be all compilers after this one.  -mtune=mckinley didn't
work very well in the early gcc 3 compilers and didn't exist in
version 2.
--
Dr Peter Chubb     http://www.gelato.unsw.edu.au  peterc@gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia

