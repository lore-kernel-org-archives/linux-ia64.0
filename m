From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 Jan 2004 01:36:46 +0000
Subject: Re: bk pull on ia64 linux tree
Message-Id: <16387.19374.420661.608611@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 12 Jan 2004 16:59:53 -0800 (PST), Linus Torvalds <torvalds@osdl.org> said:

  Linus> On Mon, 12 Jan 2004, David Mosberger wrote:
  >> 
  >> Note: this part:
  >> 
  >> ia64/configs/generic_defconfig      | 1045 ------------------------------------
  >> ia64/configs/generic_defconfig      | 1045 ++++++++++++++++++++++++++++++++++++
  >> is a no-op.

  Linus> No it isn't. After doing a pull, the
  Linus> ia64/confis/generic_defconfig file exists (along with all the
  Linus> bogus directories, of course).

  Linus> Not applied, please fix your tree.

Ugh, I forgot to push the fix into to bkbits.net tree.

Sorry about that.  It should be there now.

	--david

