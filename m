From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Nov 2003 19:44:46 +0000
Subject: Re: [PATCH] remove unimplemented syscalls noise
Message-Id: <marc-linux-ia64-106927110732391@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106926030617023@msgid-missing>
In-Reply-To: <marc-linux-ia64-106926030617023@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Nov 2003 11:42:16 -0500, Kyle McMartin <kyle@engsoc.carleton.ca> said:

  Kyle> Hi guys, this is a simple patch which removes the really
  Kyle> irritating sc<> messages that appear in logs.

What's wrong with dmesg -n4?  Those messages are marked KERN_DEBUG for
a reason.  BTW: Red Hat does this by default, but Debian doesn't.  In
my opinion, Red Hat does the right thing here: by default, most user's
don't care about such messages, but they're invaluable when tracking
down problems.

	--david
