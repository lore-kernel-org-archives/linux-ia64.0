From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 05 Oct 2004 07:20:02 +0000
Subject: RE: more serious sparse-detected bug (with fix)
Message-Id: <16738.19234.874996.94824@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410041312.i94DCslZ030821@napali.hpl.hp.com>
In-Reply-To: <200410041312.i94DCslZ030821@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 4 Oct 2004 21:30:20 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  >> for (i = 4; i < 8; i++) {
  >> -		retval |= unw_access_gr(&info, i, &ppr->gr[i], &nat, 0);
  >> +		unsigned long val;
  >> +
  >> +		if (unw_access_gr(&info, i, &val, &nat, 0) < 0)
  >> +			return -EIO;
  >> +		retval |= __put_user(val, &ppr->gr[i]);
  >> }

  Tony> Couldn't see why you added another local 'val' here as well as
  Tony> the one declared at the top of the function ... so I dropped this
  Tony> one.  Otherwise it *looks* good.  I've put it in my tree
  Tony> (linux-ia64-release-2.6.9) which I'll push in a few minutes.

I added the declaration in the outer scope later on and then forgot to
delete the inner declaration.  Thanks for spotting that.

  >> trivially.  Patch below should fix the problem, but it's completely
  >> untested (I don't have any testcases for getregs/putregs).

  Tony> I'd be happy to hear from anyone who does have some sort of test
  Tony> exercising this before I ask Linus to pull.  The current crop of
  Tony> bugs have shown how easy it is for the eyes to skip over typos
  Tony> in this code.

Check with the IA32EL folks.  AFAIR, that was the primary reason for
the getregs/putregs addition.

	--david
