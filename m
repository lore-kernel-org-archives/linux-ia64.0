From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 24 Feb 2003 19:12:39 +0000
Subject: [Linux-ia64] Re: strange performance behaviour with floats
Message-Id: <marc-linux-ia64-105590709805919@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805910@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805910@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 24 Feb 2003 13:25:12 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> On Sun, 23 Feb 2003 18:16:57 -0800, 
  Keith> David Mosberger <davidm@napali.hpl.hp.com> wrote:
  >> Let me say this again: you _don't_ want a single-cycle loop.  You want
  >> a 2-cycle loop that gets twice the work done as a 1-cycle loop.  That
  >> is, you'd want to decrement the loop counter by 2, compare it against
  >> zero, and branch if it's not zero yet, all the while making sure you
  >> get a 2-cycle loop.

  Keith> Now I see what you are getting at, sorry for the confusion.

No problem. ;-)

  Keith> Of course, the fact that udelay() does not use bogomips at all makes
  Keith> the whole question irrelevant.  We now return you to our regularly
  Keith> scheduled delay loop :)

True, but the code gcc generates for the BogoMIPS loops basically
looks identical to the one for udelay(), so the comments still apply.

	--david

