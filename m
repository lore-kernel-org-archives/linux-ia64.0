From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 12 Sep 2002 00:41:03 +0000
Subject: Re: [Linux-ia64] Greater than 2TB Filesystem support?
Message-Id: <marc-linux-ia64-105590701906023@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906020@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906020@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On Wed, 11 Sep 2002 09:18:00 -0500, "Eastham, M. Thomas (Anitel Technologies)" <EasthaMT@bp.com> said:
Thomas> Is there anyone out there that can give me an indication of
Thomas> when the 2TB FS limitation will be addressed?  We are ready to
Thomas> implement XFS based IDE Raid IA64 servers with 4+TB today.
Thomas> Any information you can provide me about timelines would be
Thomas> very helpful.

David> Peter Chubb from the University of New South Wales has done
David> some very nice work in this regard as part of the Gelato
David> project.  He has a web page and patches for the 2.5 kernel
David> series at:

David> 	http://www.gelato.unsw.edu.au/~peterc/lfs.html

I'm working on a backport to 2.4; also I haven't recently updated the
2.5 IA64 port --- if you want it I can do it today and test tomorrow.

Which kernel are you interested in?

--
Dr Peter Chubb				    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.

