From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 11 Sep 2002 18:03:58 +0000
Subject: Re: [Linux-ia64] Greater than 2TB Filesystem support?
Message-Id: <marc-linux-ia64-105590701906022@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906020@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906020@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 11 Sep 2002 09:18:00 -0500, "Eastham, M. Thomas (Anitel Technologies)" <EasthaMT@bp.com> said:

  Thomas> Is there anyone out there that can give me an indication of
  Thomas> when the 2TB FS limitation will be addressed?  We are ready
  Thomas> to implement XFS based IDE Raid IA64 servers with 4+TB
  Thomas> today.  Any information you can provide me about timelines
  Thomas> would be very helpful.

Peter Chubb from the University of New South Wales has done some very
nice work in this regard as part of the Gelato project.  He has a web
page and patches for the 2.5 kernel series at:

	http://www.gelato.unsw.edu.au/~peterc/lfs.html

I fully expect this to be part of 2.6.  I'm not sure whether anybody
has tried to back-port it to 2.4.

	--david

