From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 10 Aug 2001 17:37:17 +0000
Subject: Re: [Linux-ia64] ping(8) faster than light (do_get_fast_time) (fwd)
Message-Id: <marc-linux-ia64-105590698805057@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805052@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805052@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 10 Aug 2001 17:41:26 +0200 (CEST), Martin Wilck <Martin.Wilck@fujitsu-siemens.com> said:

  Martin> Yes, but get_fast_time() doesn't (see above), and that's the
  Martin> function that is called for getting timestamps for socket
  Martin> buffers.

Ah, yes, my oversight.  We should initialize do_get_fast_time.  Thanks
for tracking this down.

	--david

