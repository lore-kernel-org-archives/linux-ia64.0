From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Sep 2003 00:37:46 +0000
Subject: RE: kernel update (relative to 2.6.0-test5)
Message-Id: <marc-linux-ia64-106429272320091@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106309120628711@msgid-missing>
In-Reply-To: <marc-linux-ia64-106309120628711@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 9 Sep 2003 13:09:44 -0700, "Wichmann, Mats D" <mats.d.wichmann@intel.com> said:

  >> The latest ia64 patch relative to 2.6.0-test5 is available at
  >> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5
  >> in:

  >> linux-2.6.0-test5-ia64-030908.diff.gz

  Mats> For symmetry with the mainline kernel, shouldn't
  Mats> these be going into a v2.6 directory?

Well, it's a bit strange that the bk repo continues to be called
-2.5, but what the heck, I made the analogous change for the
ia64 ftp directory.  That is, I moved all the 2.6.0-testN patches
to:

	ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.6/

and changed the bk-to-html script to update:

	kernel.org/pub/linux/kernel/ports/ia64/v2.6/testing/cset/index.html

Thanks,

  --david

