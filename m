From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 21 Apr 2004 23:01:17 +0000
Subject: Re: [PATCH] module relocation code
Message-Id: <16518.64829.417223.202223@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0404211718200.1782-100000@daphne.frec.bull.fr>
In-Reply-To: <Pine.LNX.4.44.0404211718200.1782-100000@daphne.frec.bull.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 22 Apr 2004 00:50:59 +0200 (CEST), Jean-Marc Saffroy <jean-marc.saffroy@ext.bull.net> said:

  Jean-Marc> When val and location are both in init or both in core,
  Jean-Marc> there's nothing to do[*]. When val and location are in
  Jean-Marc> different areas, I always use a plt (and then a function
  Jean-Marc> descriptor for val is needed if val is in the module).

Yes, the code is probably fine, but I think it could be structured
better for better.

  Jean-Marc> [*] unless the text grows larger than 32MB, now that I
  Jean-Marc> think about it. It may be better to use a plt depending
  Jean-Marc> on the offset between val and plt, after all.

The entire kernel is much smaller than that.  Let's not overengineer
the solution.  As long as the >32MB case is detected and a suitable
error message is printed, that should be fine.

BTW: a PLT is also a bit of overkill.  What you're doing is similar to
what the GNU linker calls "relaxation" (extending the reach of a
branch), since the gp value is the same for the caller and the callee.

	--david
