From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Date: Thu, 02 Jun 2011 10:07:12 +0000
Subject: Re: [PATCH] ia64: Hook up gpiolib support
Message-Id: <20110602100712.GD3085@opensource.wolfsonmicro.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1306921697-31045-1-git-send-email-broonie@opensource.wolfsonmicro.com>
In-Reply-To: <1306921697-31045-1-git-send-email-broonie@opensource.wolfsonmicro.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 01, 2011 at 02:07:11PM -0700, Tony Luck wrote:

> But is there anything that I can do with it to show that it is working
> correctly?

Not really - you can build drivers that use gpiolib but unless you
obtain some hardware which uses it or write a virtual GPIO driver and a
consumer for it there's not really a lot doing except build tests.  Like
I said in the changelog the main thought here was to make build coverage
easier in a way that is more useful than bodging around optionally
available stuff.
