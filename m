From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 16 Nov 2005 06:09:46 +0000
Subject: RE: [PATCH] RFC : Page table macros
Message-Id: <200511160609.jAG69kg15020@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051116050037.GF2440@cse.unsw.EDU.AU>
In-Reply-To: <20051116050037.GF2440@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ian Wienand wrote on Tuesday, November 15, 2005 9:01 PM
> Please find below a patch to make some page table modifications
> similar to something I posted earlier before the 4 level stuff.

I'm not so sure about the change in ivt.S.  It makes the code a
lot harder to read.  After all, the asm code in ivt.S is very
low level and deal with all the low level detail anyway.  You
aren't going to get away with more macros.

- Ken

