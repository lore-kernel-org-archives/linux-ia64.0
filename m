From: Tony Luck <tony.luck@intel.com>
Date: Tue, 01 Jun 2010 18:11:46 +0000
Subject: Re: question about arch/ia64/kernel/iosapic.c
Message-Id: <AANLkTimgjaJHnZgqid_A_REynpV-2W9aJKB4JBTmkWk9@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.1005300754160.12022@ask.diku.dk>
In-Reply-To: <Pine.LNX.4.64.1005300754160.12022@ask.diku.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Sat, May 29, 2010 at 10:56 PM, Julia Lawall <julia@diku.dk> wrote:
> I have the impression that ioremap should not be called with locks held.
> Is this the case? =A0If so, what should be done in the following code (fr=
om
> the function iosapic_init):

This code is probably safe because on any sane system the I/O address
being mapped should not fall into any of the complex cases in ioremap().
So we'll just end up in __ioremap() ... which just does some simple math
to get the region 6 address that provides uncacheable access to the
physical address - which can safely be done while holding a lock.

Did you find this because you have a code scanner that is flagging
this as a problem?

-Tony
