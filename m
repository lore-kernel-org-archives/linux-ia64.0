From: Jes Sorensen <jes@wildopensource.com>
Date: Mon, 20 Oct 2003 08:46:03 +0000
Subject: Re: [patch] xbow.c kmalloc fixes
Message-Id: <marc-linux-ia64-106663983914643@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106641220628729@msgid-missing>
In-Reply-To: <marc-linux-ia64-106641220628729@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

David> So what should be done about these SN2 cleanups?  I don't want
David> to accept dozens of small "fixes" (which really are mostly
David> cleanups) as that would defeat the idea of the code-fixes-only
David> decree.  On the other hand, I really would like to see the SN2
David> code cleaned up so we actually have a sane base to do bug fixes
David> on top of.

Hi David,

I am in two minds over this, I agree that getting the sn2 code cleaned
up is a big win and a lot of the changes like those I posted are
clearly bug fixes (not checking kmalloc returns should always be
fixed). However having a big patch will take time and means we will
have to operate with an internal tree until we get the whole thing
into shape to push, but the seperate tree is one of the things we have
been trying to avoid with 2.6. What came first, the chicken or the
soft boiled egg ;-(

Cheers,
Jes
