From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 20 Oct 2003 18:25:02 +0000
Subject: Re: [patch] xbow.c kmalloc fixes
Message-Id: <marc-linux-ia64-106667462922380@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106641220628729@msgid-missing>
In-Reply-To: <marc-linux-ia64-106641220628729@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 20 Oct 2003 04:46:03 -0400, Jes Sorensen <jes@wildopensource.com> said:

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:
  David> So what should be done about these SN2 cleanups?  I don't
  David> want to accept dozens of small "fixes" (which really are
  David> mostly cleanups) as that would defeat the idea of the
  David> code-fixes-only decree.  On the other hand, I really would
  David> like to see the SN2 code cleaned up so we actually have a
  David> sane base to do bug fixes on top of.

  Jes> I am in two minds over this, I agree that getting the sn2 code
  Jes> cleaned up is a big win and a lot of the changes like those I
  Jes> posted are clearly bug fixes (not checking kmalloc returns
  Jes> should always be fixed). However having a big patch will take
  Jes> time and means we will have to operate with an internal tree
  Jes> until we get the whole thing into shape to push, but the
  Jes> seperate tree is one of the things we have been trying to avoid
  Jes> with 2.6. What came first, the chicken or the soft boiled egg
  Jes> ;-(

The issue may be moot already.  Now that test8 is out, I'm not sure
Andrew/Linus would still accept large at all patches anymore.

	--david
