From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 16 Sep 2003 19:04:00 +0000
Subject: Re: NFS server problems in 2.6.0-test[4,5]
Message-Id: <marc-linux-ia64-106373916805349@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106366548926386@msgid-missing>
In-Reply-To: <marc-linux-ia64-106366548926386@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

--text follows this line--
  Matthew> On Mon, Sep 15, 2003 at 03:36:16PM -0700, David Mosberger wrote:
  >> Has there been any progress in getting the NFS server debugged?

  Matthew> Yep, on the NFS mailing list ... here's the latest patch courtesy
  Matthew> of Neil Brown & Trond.  I still get a 5:30 minute hang when mounting
  Matthew> my ia64 NFS server, but that's probably something else.

  Matthew> Wouldn't surprise me if this affects other 64 bit arches too.

I'm glad I asked...

The patch works fine for me.  I don't see any hangs either.

Thanks,

	--david
