From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 25 Sep 2003 02:04:55 +0000
Subject: Unaligned access question
Message-Id: <marc-linux-ia64-106445553030155@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106445366428887@msgid-missing>
In-Reply-To: <marc-linux-ia64-106445366428887@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Ian" = Ian Wienand <ianw@gelato.unsw.edu.au> writes:

Ian> Hi,

Ian> This isn't directly related to kernel development, but I am a bit
Ian> stumped as to why my test program below causes an unaligned
Ian> access when 'i' is 7 (that is, when it tries to access across a
Ian> 64 bit boundary of 'array').  It's counter intuitive to me, I
Ian> would have expected it either fault on all loads (for every value
Ian> of 'i') or to have not faulted at all.

The IA64 can handle unaligned acceses itself if they're within a small
window -- eight bytes for Itanium-2, can't remember for Itanium-I --
and if PSR.ac is 0.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.
