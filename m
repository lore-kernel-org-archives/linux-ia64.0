From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 03 Nov 2003 22:35:55 +0000
Subject: Re: [PATCH] Bug in sn_pci_map_sg causes MCA
Message-Id: <marc-linux-ia64-106789901920292@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106789192810902@msgid-missing>
In-Reply-To: <marc-linux-ia64-106789192810902@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 3 Nov 2003 16:07:53 -0600 (CST), Alan Mayer <ajm@sgi.com> said:

  Alan> Sorry, here's one that should actually work:

Well, no it doesn't apply with patch -p1.  But it's OK this time, I fixed
it myself.

	--david
