From: Keith Owens <kaos@sgi.com>
Date: Mon, 24 Feb 2003 02:25:12 +0000
Subject: [Linux-ia64] Re: strange performance behaviour with floats
Message-Id: <marc-linux-ia64-105590709805914@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805910@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805910@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 23 Feb 2003 18:16:57 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>Let me say this again: you _don't_ want a single-cycle loop.  You want
>a 2-cycle loop that gets twice the work done as a 1-cycle loop.  That
>is, you'd want to decrement the loop counter by 2, compare it against
>zero, and branch if it's not zero yet, all the while making sure you
>get a 2-cycle loop.

Now I see what you are getting at, sorry for the confusion.

Of course, the fact that udelay() does not use bogomips at all makes
the whole question irrelevant.  We now return you to our regularly
scheduled delay loop :)


