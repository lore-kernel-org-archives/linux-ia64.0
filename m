From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 19 Nov 2001 17:02:52 +0000
Subject: Re: [Linux-ia64] Fixed addresses in kernel address space
Message-Id: <marc-linux-ia64-105590698805534@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805533@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805533@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 19 Nov 2001 10:11:08 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> Hi everybody!  For a driver I am writing, I would need
  Christian> access to some storage below e000000004400000. There is a
  Christian> range from e000000004000000 to e000000004400000 that is
  Christian> mapped by the kernel translation but not used in
  Christian> system.map (kernel 2.4.4). Is it possible to use part of
  Christian> this storage or are there restrictions/other usage? Can I
  Christian> rely on this unused storage in the future or is this
  Christian> subject to change?

There should be no need for using absolute addresses.  Please explain
what you're trying to do.

	--david

