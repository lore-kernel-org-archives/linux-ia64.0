From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 15 Feb 2005 19:19:40 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <16914.19276.477111.336616@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 15 Feb 2005 13:11:20 -0600, Robin Holt <holt@sgi.com> said:

  Robin> We saw many silent data corruptions. The SN2 hardware will
  Robin> give an MCA if both types of references are made by the cpu
  Robin> at about the same time, but that depends on both transactions
  Robin> being on the bus in close relationship to each other.

Yes, but the point is it affects _most_ of today's machines, including
x86.  A while ago, there were some nasty data corruption issues on AMD
chips caused by the AGP GART and the large mappings used by the Linux
kernel, for example.

	--david
