From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 02 Feb 2005 22:50:45 +0000
Subject: Re: PATCH: Fix 2.6 kernel ia64 directives
Message-Id: <16897.22853.619588.468436@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050202221918.GA7973@lucon.org>
In-Reply-To: <20050202221918.GA7973@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 2 Feb 2005 14:19:18 -0800, "H. J. Lu" <hjl@lucon.org> said:

  HJ> The new ia64 assembler caught a few directive bugs.

  HJ> -END(idirty_bit)
  HJ> +END(dirty_bit)

While I'm in favor of fixing such typos, the Itanium Assembly Language
Reference Manual states:

	"The assembler ignores the name operands of the
	 directive."

(page 35 of document 248801-004).

In my opinion, a warning might be in place, but a hard error for
something that the spec explicitly allows seems like a bad idea to me.

	--david
