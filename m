From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 02 Mar 2004 17:42:33 +0000
Subject: Re: [PATCH] sal cleanup
Message-Id: <16452.51081.409483.143571@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 2 Mar 2004 15:56:01 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> I don't have an objection to doing that, but how about
  Matthew> making it Just Work for this particular case?  Something
  Matthew> like ..

Well, that would be more convenient for me, but I don't know how many
other "strange" SAL version numbers are out there in the wild.  It's
can be handy to have an override option when dealing with buggy
firmware (fortunately, quite rare with production systems, but it's
all to common with prototypes).

Just a caveat:

  Matthew> SAL_VERSION_CODE(49, 29)

shouldn't these be in hex?

	--david
