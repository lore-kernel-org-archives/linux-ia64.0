From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 11 Nov 2003 00:59:03 +0000
Subject: Re: [PATCH] enable platform dependent MCA handling
Message-Id: <marc-linux-ia64-106851237427467@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106850974125144@msgid-missing>
In-Reply-To: <marc-linux-ia64-106850974125144@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 11 Nov 2003 09:12:20 +0900, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> said:

  Hidetoshi> Hi.  This is a patch that makes #ifdef mechanism in
  Hidetoshi> /arch/ia64/kernel/mca.c to work properly, and enable
  Hidetoshi> switching platform dependent error handling.  For
  Hidetoshi> example, this supports OS to have an OEM call-back
  Hidetoshi> function for MCAs.  Since this is a roughly scratched
  Hidetoshi> prototype, please give me your comments.

I think you ought to be machvecs for this purpose.

	--david
