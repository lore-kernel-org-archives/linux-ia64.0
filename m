From: Tony Luck <tony.luck@gmail.com>
Date: Tue, 01 Jun 2010 18:38:26 +0000
Subject: Re: question about arch/ia64/kernel/iosapic.c
Message-Id: <AANLkTilkQtsLmhRI-5o67U8stHme5QaV7HQ2Cjaf42_D@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.1005300754160.12022@ask.diku.dk>
In-Reply-To: <Pine.LNX.4.64.1005300754160.12022@ask.diku.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 1, 2010 at 11:15 AM, Julia Lawall <julia@diku.dk> wrote:
> Yes, but the question was more because I was trying to understand whether
> the scanner should be looking for ioremap problems or not.

Adding Bjorn as he wrote all of the code in the current version
of ioremap().

IIRC the original version of ioremap() just did what __ioremap() does
now ... people using ioremap() for more creative purposes prompted
the complexity to make sure that we didn't mix cacheable and
uncacheable accesses.  Most core kernel use of ioremap() will
still end up in __ioremap() ... so there would be no ill effects from
those calls if done from code that holds locks.

Are there many spots in arch/ia64 that are flagged?

-Tony
