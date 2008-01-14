From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 14 Jan 2008 23:34:05 +0000
Subject: RE: [PATCH] Fix unaligned handler for floating point instructions with base update
Message-Id: <1FE6DD409037234FAB833C420AA843EC50E17F@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC50D9B4@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC50D9B4@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This sounds like a case of the kernel corrupting user data.  Are you
> pushing this into the distro kernels?  Do you have bugzilla numbers?

Yes, the kernel is corrupting user data.  I'm not aware of bugzilla
entries for this at the distros (I only became aware of the issue on
Thursday afternoon).  I agree that it needs to go to the distros.
My bugzilla searching skills are bad (I usually can't find bugs that
I know are in there, for which I have all the right keywords :-( )
So if anyone knows of existing bugs that might be caused by this
problem ... let me know.  Otherwise I can open new entries when
I send this patch to Linus.

I'm a little puzzled that this hasn't been found before.  The code
in unaligned.c has been essentially the same since the dawn of ia64
time ... very early 2.4.x releases just used a "? :" rather than
an "if ... else", so the patch would need some massaging before
it could be applied to 2.4.3 or earlier.  I'm assuming that we haven't
hit this before because either (or both) of these are true:
1) Most FP access to memory is aligned.
2) Compilers are not generating the "ldf fX = [rY], off" (and other
   mis-decoded variations) very often.

Meanwhile ... if you could stare at the code and pages 3:302 - 3:306
of the SDM for a while to check my patch for stupidity, that would
be extremely helpful.

-Tony
